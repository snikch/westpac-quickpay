//
//  WebClient.h
//
//
//  Created by Mal Curtis on 19/04/14.
//
//

#import <Foundation/Foundation.h>
#import <NJKWebViewProgress.h>

@interface WebClient : NSObject <UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (strong, nonatomic) UIWebView *view;
@property (strong, nonatomic) NJKWebViewProgress * progressProxy;

-(void) loginWithUsername:(NSString*)username
                 password:(NSString*)password
                  success: (void (^)()) successBlock
                  failure: (void (^)(NSError * error)) failureBlock
                 progress: (void (^)(float progress)) progressBlock;

-(void) loadPayees: (void (^)(NSArray *payees)) successBlock
                  failure: (void (^)(NSError * error)) failureBlock;
@end
