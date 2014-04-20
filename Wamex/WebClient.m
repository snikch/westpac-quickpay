//
//  WebClient.m
//
//
//  Created by Mal Curtis on 19/04/14.
//
//

#import "WebClient.h"
#import "UIWebView+Blocks.h"
#import "Settings.h"

@implementation WebClient

-(id) init{
    self = [super init];
    self.view = [[UIWebView alloc]init];
    
    [self initProgressProxy];
    return self;
}

-(void)initProgressProxy{
    // Use WebViewProgress as a proxy delegate so we can get a good idea of progress
    self.progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
    self.view.proxyDelegate = self.progressProxy;
    self.view.delegate = self.progressProxy;
    self.progressProxy.webViewProxyDelegate = self;
}
/**
 * Attempt to login - visit the login page, enter the credentials and see what happens
 */
-(void) loginWithUsername:(NSString*)username
                 password:(NSString*)password
                  success: (void (^)()) successBlock
                  failure: (void (^)(NSError * error)) failureBlock
                 progress: (void (^)(float progress)) progressBlock
{
    NSLog(@"Loading Westpac");
    // write javascript code in a string
    NSString* jsString = @"document.getElementsByName('%@')[0].value=\"%@\";document.getElementsByName('%@')[0].value=\"%@\";document.getElementsByClassName('button')[0].children[0].click()";
    
    jsString = [NSString stringWithFormat:jsString, kLoginFormUsernameName, username, kLoginFormPasswordName, password];
    NSLog(@"%@", jsString);
   
    
    __block BOOL started = NO;
    __block BOOL guardian = NO;
    __block BOOL finished = NO;
    __block float lastProgress;
    __block NSDate *loginStartTime;
    __block void(^checkLoggedIn)(void);
    
    self.progressProxy.progressBlock = ^(float progress){
        progress = (progress / 3.0);
        if (guardian == YES){
            progress += 0.66;
        }else if (started == YES){
            progress += 0.33;
        }
        if(progress > lastProgress){
            lastProgress = progress;
            progressBlock(progress);
        }
    };
    
    // Block to load the login page and submit details
    void (^loaded)(UIWebView *webView) = ^(UIWebView *webView) {
        NSLog(@"loaded");
        if(started == NO){
            NSLog(@"Running javascript");
            started = YES;
            [webView stringByEvaluatingJavaScriptFromString: jsString];
            [self.view setLoadedBlock:^(UIWebView *view){
                checkLoggedIn();
            }];
            [self.view setFailureBlock:^(UIWebView *view, NSError *error){
                checkLoggedIn();
            }];
            loginStartTime = [NSDate date];
            
        }
        
    };
    
    __block double loginTimeout = 10.0;
    
    // Block to check for login success and throw through to failure block
    checkLoggedIn = ^(void) {
        if (finished == YES){
            return;
        }
        // Are we logged in?
        if([self pageHasContent:@"your last login"]){
            NSLog(@"Logged in");
            self.progressProxy.progressBlock = nil;
            finished = YES;
            NSString *csv = [self.view stringByEvaluatingJavaScriptFromString:jsAccountNames];
            NSArray *accounts = [csv componentsSeparatedByString:@","];
            successBlock(accounts);
            return;
        }
        if([self pageHasContent:@"guardian"]){
            guardian = YES;
        }
        // Is there an error message?
        if([self pageHasContent:@"login attempt was unsuccessful"]){
            NSLog(@"Login failure");
            self.progressProxy.progressBlock = nil;
            finished = YES;
            failureBlock(nil);
            return;
        }
        // We're still on the login page, def wait
        //"Enter your Customer ID"
        // Keep waiting, maybe on guardian page?
        NSTimeInterval timeInterval = [loginStartTime timeIntervalSinceNow];
        if(timeInterval > loginTimeout){
            NSLog(@"Login timeout");
            self.progressProxy.progressBlock = nil;
            finished = YES;
            failureBlock(nil);
            return;
        }
    };
    
    // Block to throw failures through to the calling failure block
    void (^failed)(UIWebView *webView, NSError *error) = ^(UIWebView *webView, NSError *error) {
        NSLog(@"Ignoring failure %@", error);
        //failureBlock(error);
    };
    
    [self.view loadRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:kUrlLogin]] loaded:loaded failed:failed];
}

/**
 * Attempt to get the list of payees. Assumes we're logged in.
 */
-(void) loadPayees:(void (^)(NSArray *payees)) successBlock
                  failure: (void (^)(NSError * error)) failureBlock
{
    NSLog(@"Loading Payees");
    __block void(^paymentsLoaded)(UIWebView *webView);
    __block void(^payeesLoaded)(UIWebView *webView);
    
    // Load the payments page
    paymentsLoaded = ^(UIWebView *webView) {
        [self clickElementWithName:kPrintPayeeListName complete:payeesLoaded];
    };
    // Loads the payee print page
    payeesLoaded = ^(UIWebView *webView) {
        NSString *csv = [self.view stringByEvaluatingJavaScriptFromString:jsPayeeNames];
        NSArray *payees = [csv componentsSeparatedByString:@","];
        successBlock(payees);
    };
    
    [self clickElementWithName:kTransferMoneyName complete:paymentsLoaded];

    
    // Block to throw failures through to the calling failure block
    void (^failed)(UIWebView *webView, NSError *error) = ^(UIWebView *webView, NSError *error) {
        NSLog(@"Ignoring failure %@", error);
        //failureBlock(error);
    };
    [self.view setFailureBlock:failed];
}

-(void)makePaymentFrom: (NSString*)account
                    to: (NSString*)payee
                   for:(NSNumber*)amount
         withReference: (NSString*)reference
               success: (void (^)()) successBlock
               failure: (void (^)(NSError * error)) failureBlock
              progress: (void (^)(double progress, NSString* state)) progressBlock
{
    if (amount == NULL){
        progressBlock(0, nil);
        failureBlock(nil);
    }
    if(reference == NULL){
        reference = @"";
    }
    NSLog(@"Make payment from %@ to %@ for %@ with ref %@", account, payee, amount, reference);
    float steps = 5.0;
    __block float step = 1.0;
    __block void(^loggedIn)(void);
    __block void(^paymentsLoaded)(UIWebView *webView);
    __block void(^makePayment)(UIWebView *webView);
    __block void(^confirmationPageLoaded)(UIWebView *webView);
    __block void(^paymentMade)(UIWebView *webView);
    
    __block float lastProgress;
    

    
    loggedIn = ^(void){
        self.progressProxy.progressBlock = ^(float progress){
            progress = progress / steps;
            progress += (step - 1.0) * (1.0/steps);
            if(progress > lastProgress){
                lastProgress = progress;
                progressBlock(progress, nil);
            }
            NSLog(@"payment progress: %f", progress);
        };
        progressBlock(step/steps, @"Logged In");
        step = 2.0;
        [self clickElementWithName:kTransferMoneyName complete:paymentsLoaded];
    };
    
    paymentsLoaded = ^(UIWebView *webView) {
        progressBlock(step/steps, @"Creating");
        step = 3.0;
        [self clickElementWithName:kMakePaymentsName complete:makePayment];
    };
    
    makePayment = ^(UIWebView *webView){
        progressBlock(step/steps, @"Creating");
        step = 4.0;
        NSString *jsString = [NSString stringWithFormat:jsSetPaymentAccount, account];
        [self.view stringByEvaluatingJavaScriptFromString: jsString];
        jsString = [NSString stringWithFormat:jsSetPaymentDetails, payee, amount, reference];
        [self.view stringByEvaluatingJavaScriptFromString: jsString];
        [self clickElementWithId:kMakePaymentNextStepId complete:confirmationPageLoaded];
    };
    
    confirmationPageLoaded = ^(UIWebView *webView) {
        progressBlock(step/steps, @"Confirming");
        step = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [self clickElementWithId:kMakePaymentConfirmId complete:paymentMade];
        });
    };
    
    paymentMade = ^(UIWebView *webView) {
        if([self pageHasContent:@"duplicate"]){
            progressBlock(0.0, @"Duplicate");
            failureBlock(nil);
        }else if([self pageHasContent:@"your records"]){
            progressBlock(0.0, @"Payment Made");
            successBlock();
        }else{
            progressBlock(0.0, @"Not Sure…");
            failureBlock(nil);
        }
    };
    
    progressBlock(0.0, @"Logging in");
    
    [self loginWithUsername:[Settings username] password:[Settings password] success:^{
        NSLog(@"Success");
        progressBlock(1.0/steps, @"Logged In");
        loggedIn();
    } failure:^(NSError *error) {
        //failureBlock(nil);
    } progress:^(float progress) {
        NSLog(@"Getting Progress");
        progressBlock(progress/steps, NULL);
    }];
    
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^{
//        successBlock();
//    });
}


-(BOOL)pageHasContent:(NSString*)string{
    NSLog(@"Checking if page has content: %@", string);
    NSString * matchString = [NSString stringWithFormat:@"!!document.body.innerHTML.match(/%@/)", string];
    NSString * match = [self.view stringByEvaluatingJavaScriptFromString:matchString];
    return [match isEqualToString:@"true"];
}

-(void)clickElementWithName: (NSString*) name complete:(void (^)(UIWebView *webView)) completeBlock {
    NSString *jsString = [NSString stringWithFormat:@"document.getElementsByName('%@')[0].click()", name];
    NSString *result = [self.view stringByEvaluatingJavaScriptFromString: jsString];
    NSLog(@"Result of click: %@", result);
    [self.view setLoadedBlock:completeBlock];
}

-(void)clickElementWithId: (NSString*) id complete:(void (^)(UIWebView *webView)) completeBlock {
    NSString *jsString = [NSString stringWithFormat:@"document.getElementById('%@').click()", id];
    NSString *result = [self.view stringByEvaluatingJavaScriptFromString: jsString];
    NSLog(@"Result of click: %@", result);
    [self.view setLoadedBlock:completeBlock];
}
@end
