//
//  PaymentController.h
//  Wamex
//
//  Created by Mal Curtis on 19/04/14.
//  Copyright (c) 2014 Mal Curtis. All rights reserved.
//

#import "XLFormViewController.h"

@interface PaymentController : XLFormViewController <UIPopoverControllerDelegate>
@property BOOL dirty;
- (IBAction)togglePopover:(id)sender;
@end
