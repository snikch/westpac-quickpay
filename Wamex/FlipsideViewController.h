//
//  FlipsideViewController.h
//  Wamex
//
//  Created by Mal Curtis on 19/04/14.
//  Copyright (c) 2014 Mal Curtis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XLForm.h>
#import "WebClient.h"

@class FlipsideViewController;


@interface FlipsideViewController : XLFormViewController

@property BOOL hasEnteredCredentials;
@property BOOL canCheckCredentials;
@property (strong, nonatomic) NSArray *accounts;
@property (strong, nonatomic) NSArray *payees;
@property (strong, nonatomic) WebClient *client;

- (IBAction)done:(id)sender;

@end
