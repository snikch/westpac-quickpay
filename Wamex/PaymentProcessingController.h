//
//  PaymentProcessingController.h
//  Wamex
//
//  Created by Mal Curtis on 20/04/14.
//  Copyright (c) 2014 Mal Curtis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebClient.h"


@interface PaymentProcessingController : UIViewController

@property (strong, nonatomic) NSString *account;
@property (strong, nonatomic) NSString *payee;
@property (strong, nonatomic) NSString *reference;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) WebClient *client;


@end
