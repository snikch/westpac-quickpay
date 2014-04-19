//
//  WebClient.m
//
//
//  Created by Mal Curtis on 19/04/14.
//
//

#import "WebClient.h"
#import "UIWebView+Blocks.h"

@implementation WebClient

-(id) init{
    self = [super init];
    self.view = [[UIWebView alloc]init];
    
    self.progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
    self.view.delegate = self.progressProxy;
    self.progressProxy.webViewProxyDelegate = self;
    return self;
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
    
    self.progressProxy.progressBlock = progressBlock;
    
    __block BOOL started = NO;
    __block BOOL finished = NO;
    __block NSDate *loginStartTime;
    __block void(^checkLoggedIn)(void);
    
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
    double loginDelay = 1.0;
    
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
            successBlock();
            return;
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

-(BOOL)pageHasContent:(NSString*)string{
    NSLog(@"Checking if page has content: %@", string);
    NSString * matchString = [NSString stringWithFormat:@"!!document.body.innerHTML.match(/%@/)", string];
    NSString * match = [self.view stringByEvaluatingJavaScriptFromString:matchString];
    return [match isEqualToString:@"true"];
}

-(void)clickElementWithName: (NSString*) name complete:(void (^)(void)) completeBlock {
    NSString *jsString = [NSString stringWithFormat:@"document.body.getElementsByName('%@')[0].click", name];
    [self.view stringByEvaluatingJavaScriptFromString: jsString];
}
@end
