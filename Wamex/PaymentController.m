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
#import "PaymentProcessingController.h"

@implementation PaymentController

-(id)init
{
    NSLog(@"Initializing form");
    UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
    [self.navigationItem setRightBarButtonItem: settings];
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"Make Payment"];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"amount" rowType:XLFormRowDescriptorTypeNumber title:@"Amount"];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"reference" rowType:XLFormRowDescriptorTypeText title:@"Reference"];
    [section addFormRow:row];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *payee = [defaults stringForKey:@"payee"];
    NSString *account = [defaults stringForKey:@"account"];
    NSArray *payees = [defaults objectForKey:@"payees"];
    NSArray *accounts = [defaults objectForKey:@"accounts"];
    
    // Payee
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"payee" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Payee"];
    [Settings loadArray: payees intoRow: row withDefault: payee];
    [section addFormRow:row];
    
    // Account
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"account" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Account"];
    [Settings loadArray: accounts intoRow: row withDefault: account];
    [section addFormRow:row];
    
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // Title
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"makePayment" rowType:XLFormRowDescriptorTypeButton title:@"Pay"];
    [row.cellConfig setObject:[UIColor greenColor] forKey:@"textLabel.textColor"];
    
    [section addFormRow:row];
    
    
    self = [self initWithForm:form formMode:XLFormModeCreate showCancelButton:NO showSaveButton:NO showDeleteButton:NO deleteButtonCaption:nil];
    
    self.showNetworkReachability = YES;
    self.form.assignFirstResponderOnShow = YES;
    return self;

}

#pragma mark - XLFormDescriptorDelegate

-(void)didSelectFormRow:(XLFormRowDescriptor *)formRow{
    [super didSelectFormRow:formRow];
    if([formRow.tag isEqualToString:@"makePayment"]){
        [self makePayment];
    }
    
}

-(void)makePayment{
    
    NSString *reference = [self.form formRowWithTag:@"reference"].value;
    NSNumber *amount = [self.form formRowWithTag:@"amount"].value;
    XLFormOptionsObject *accountOption = [self.form formRowWithTag:@"account"].value;
    XLFormOptionsObject *payeeOption = [self.form formRowWithTag:@"payee"].value;
    NSString *payee = payeeOption.formValue;
    NSString *account = accountOption.formValue;
    PaymentProcessingController *pc = [[PaymentProcessingController alloc] init];
    
    pc.amount = amount;
    pc.account = account;
    pc.payee = payee;
    pc.reference = reference;
    
    [self.navigationController pushViewController:pc animated:YES];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Change the selected background view of the cell.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end
