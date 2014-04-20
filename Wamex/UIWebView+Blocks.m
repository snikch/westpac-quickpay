//
//  UIWebView+Blocks.m
//
//  Created by Shai Mishali on 1/1/13.
//  Copyright (c) 2013 Shai Mishali. All rights reserved.
//

#import "UIWebView+Blocks.h"
#import <objc/runtime.h>

void (^__loadedBlock)(UIWebView *webView);
void (^__failureBlock)(UIWebView *webView, NSError *error);
void (^__loadStartedBlock)(UIWebView *webView);
BOOL (^__shouldLoadBlock)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType);

uint __loadedWebItems;

@implementation UIWebView (Block)

#pragma mark - UIWebView+Blocks

-(void)setProxyDelegate:(id)proxyDelegate{
    objc_setAssociatedObject(self,@selector(proxyDelegate),proxyDelegate, OBJC_ASSOCIATION_RETAIN);
}

-(id)proxyDelegate{
    return (id)objc_getAssociatedObject(self, @selector(proxyDelegate));
}

-(void)loadRequest:(NSURLRequest *)request
                   loaded:(void (^)(UIWebView *webView))loadedBlock
                   failed:(void (^)(UIWebView *webView, NSError *error))failureBlock{
    
    [self loadRequest:request loaded:loadedBlock failed:failureBlock loadStarted:nil shouldLoad:nil];
}

-(void)loadRequest:(NSURLRequest *)request
                   loaded:(void (^)(UIWebView *webView))loadedBlock
                   failed:(void (^)(UIWebView *webView, NSError *error))failureBlock
              loadStarted:(void (^)(UIWebView *webView))loadStartedBlock
               shouldLoad:(BOOL (^)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType))shouldLoadBlock{
    __loadedWebItems    = 0;
    
    __loadedBlock       = loadedBlock;
    __failureBlock      = failureBlock;
    __loadStartedBlock  = loadStartedBlock;
    __shouldLoadBlock   = shouldLoadBlock;
    
    if(self.delegate){
        self.proxyDelegate = self.delegate;
    }
    self.delegate    = self;
    
    [self loadRequest: request];
    
}

-(void)setLoadedBlock: (void (^)(UIWebView *webView)) block{
    __loadedBlock = block;
}

-(void)setFailureBlock: (void (^)(UIWebView *webView, NSError *error)) block{
    __failureBlock = block;
}

#pragma mark - Private Static delegate
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    if (self.proxyDelegate) {
        [self.proxyDelegate webViewDidFinishLoad:webView];
    }
    __loadedWebItems--;
    
    if(__loadedBlock && (!TRUE_END_REPORT || __loadedWebItems == 0)){
        __loadedWebItems = 0;
        __loadedBlock(webView);
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if (self.proxyDelegate) {
        [self.proxyDelegate webView:webView didFailLoadWithError:error];
    }
    __loadedWebItems--;
    
    if(__failureBlock)
        __failureBlock(webView, error);
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    if (self.proxyDelegate) {
        [self.proxyDelegate webViewDidStartLoad:webView];
    }
    __loadedWebItems++;
    
    if(__loadStartedBlock && (!TRUE_END_REPORT || __loadedWebItems > 0))
        __loadStartedBlock(webView);
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (self.proxyDelegate) {
        [self.proxyDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    if(__shouldLoadBlock)
        return __shouldLoadBlock(webView, request, navigationType);
    
    return YES;
}



@end