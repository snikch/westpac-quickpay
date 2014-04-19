//
//  MainViewController.m
//  Wamex
//
//  Created by Mal Curtis on 19/04/14.
//  Copyright (c) 2014 Mal Curtis. All rights reserved.
//

#import "MainViewController.h"
#import "PaymentController.h"

@interface MainViewController ()

@end

@implementation MainViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    PaymentController *vc = [[PaymentController alloc] init];
    [self setViewControllers:@[vc] animated:NO];
}

@end
