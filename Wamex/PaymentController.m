//
//  PaymentController.m
//  Wamex
//
//  Created by Mal Curtis on 19/04/14.
//  Copyright (c) 2014 Mal Curtis. All rights reserved.
//

#import "PaymentController.h"
#import "Settings.h"
#import "SettingsNavigationViewController.h"

@implementation PaymentController

-(id)init
{
    NSLog(@"Initializing form");
    UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
    [self.navigationItem setRightBarButtonItem: settings];
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"Settings"];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"amount" rowType:XLFormRowDescriptorTypeNumber title:@"Amount"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"payee" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Payee"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"account" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Account"];
    [section addFormRow:row];
    
    // Add the 'check' button
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // Title
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"login" rowType:XLFormRowDescriptorTypeButton title:@"Pay"];
    [row.cellConfig setObject:[UIColor grayColor] forKey:@"textLabel.textColor"];
    
    [section addFormRow:row];
    
    
    self = [self initWithForm:form formMode:XLFormModeCreate showCancelButton:NO showSaveButton:NO showDeleteButton:NO deleteButtonCaption:nil];
    
    self.showNetworkReachability = YES;
    self.form.assignFirstResponderOnShow = YES;
    return self;

}
-(void)viewDidAppear:(BOOL)animated{
    if(![Settings isSetup]){
        [self showSettings];
    }
}

-(void) showSettings{
    SettingsNavigationViewController * viewController = [[SettingsNavigationViewController alloc] init];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)togglePopover:(id)sender
{
    [self showSettings];
}
@end
