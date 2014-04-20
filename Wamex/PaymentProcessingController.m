//
//  PaymentProcessingController.m
//  Wamex
//
//  Created by Mal Curtis on 20/04/14.
//  Copyright (c) 2014 Mal Curtis. All rights reserved.
//

#import "PaymentProcessingController.h"
#import <MRProgress.h>

@implementation PaymentProcessingController

-(id)init{
    self = [super init];
    if(self){
        self.view = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.client = [[WebClient alloc] init];
    
    CGRect pos = self.view.bounds;
    self.client.view.frame = pos;
    [self.view addSubview:self.client.view];
    
    
    __block MRProgressOverlayView * progressView = [[MRProgressOverlayView alloc] init];
    progressView.mode = MRProgressOverlayViewModeDeterminateCircular;
    progressView.titleLabelText = @"Starting Payment";
    [self.navigationController.view addSubview:progressView];
    [progressView show:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [progressView hide:YES];
        //[progressView removeFromSuperview];
    });
    if (self.amount == NULL){
        progressView.titleLabelText = @"Enter Amount";
        progressView.mode = MRProgressOverlayViewModeCross;
        progressView.tintColor = [UIColor redColor];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [progressView hide:YES];
            [progressView removeFromSuperview];
        });
        
        return;
    }
    
    
    [self.client makePaymentFrom:self.account
                              to:self.payee
                             for:self.amount
                   withReference:self.reference
                         success: ^{
                             progressView.titleLabelText = @"Payment Confirmed";
                             progressView.mode = MRProgressOverlayViewModeCheckmark;
                             progressView.tintColor = [UIColor greenColor];
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC);
                             dispatch_after(popTime, dispatch_get_main_queue(), ^{
                                 [progressView hide:YES];
                                 [progressView removeFromSuperview];
                             });
                         }
                         failure:^(NSError *error) {
                             progressView.mode = MRProgressOverlayViewModeCross;
                             progressView.tintColor = [UIColor redColor];
                             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC);
                             dispatch_after(popTime, dispatch_get_main_queue(), ^{
                                 [progressView hide:YES];
                                 [progressView removeFromSuperview];
                             });
                         } progress:^(double progress, NSString *state) {
                             if(state != NULL){
                                 progressView.titleLabelText = state;
                             }
                             if (progress != 0.0) {
                                 progressView.progress = progress;
                             }
                         }];
}

@end
