//
//  FlipsideViewController.m
//  Wamex
//
//  Created by Mal Curtis on 19/04/14.
//  Copyright (c) 2014 Mal Curtis. All rights reserved.
//

#import "FlipsideViewController.h"
#import "Settings.h"
#import <PDKeychainBindings.h>
#import "SettingsNavigationViewController.h"

@interface FlipsideViewController ()

@end

@implementation FlipsideViewController

-(id)init{
    self.hasEnteredCredentials = NO;
    self.client = [[WebClient alloc]init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.accounts = [defaults objectForKey:@"accounts"];
    self.payees = [defaults objectForKey:@"payees"];
    
    PDKeychainBindings *keychain = [PDKeychainBindings sharedKeychainBindings];
    NSString *username = [keychain stringForKey:@"username"];
    NSString *password = [keychain stringForKey:@"password"];
    BOOL hasInitialCredentials = password && username;
    
    // Do any additional setup after loading the view, typically from a nib.
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"Settings"];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // Title
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"username" rowType:XLFormRowDescriptorTypeAccount title:@"Customer ID"];
    row.value = username;
    [section addFormRow:row];
    
    // Location
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"password" rowType:XLFormRowDescriptorTypePassword title:@"Password"];
    row.value = password;
    [section addFormRow:row];
    
    // Add the 'check' button
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // Title
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"login" rowType:XLFormRowDescriptorTypeButton title:hasInitialCredentials ? @"Reload Data" : @"Check Credentials"];
    [row.cellConfig setObject:[UIColor grayColor] forKey:@"textLabel.textColor"];
    
    [section addFormRow:row];
    
    
    self = [self initWithForm:form formMode:XLFormModeCreate showCancelButton:hasInitialCredentials showSaveButton:hasInitialCredentials showDeleteButton:NO deleteButtonCaption:nil];
    
    self.showNetworkReachability = YES;
    [self formDidChange];
    
    if(hasInitialCredentials){
        [self showDefaultsSection];
    }else{
        self.form.assignFirstResponderOnShow = YES;
    }
    
    // Add the 'delete' button
    if (hasInitialCredentials){
        section = [XLFormSectionDescriptor formSection];
        [form addFormSection:section];
        
        // Title
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"delete" rowType:XLFormRowDescriptorTypeButton title:@"Delete Data"];
        [row.cellConfig setObject:[UIColor redColor] forKey:@"textLabel.textColor"];
        
        [section addFormRow:row];
    }
    
    
    return self;
}

#pragma mark - XLFormDescriptorDelegate
-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    [self formDidChange];
    if([rowDescriptor.tag isEqualToString:@"account"] || [rowDescriptor.tag isEqualToString:@"payee"]){
        [(XLFormSelectorCell*)[rowDescriptor cellForFormController:self] update];
    }
}

-(void)didSelectFormRow:(XLFormRowDescriptor *)formRow{
    [super didSelectFormRow:formRow];
    if([formRow.tag isEqualToString:@"login"]){
        [self checkCredentials];
    } else if([formRow.tag isEqualToString:@"delete"]){
        [self deleteData];
        [self cancelPressed:nil];
    }
    
}
-(void)deleteData{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"payees"];
    [defaults removeObjectForKey:@"payee"];
    [defaults removeObjectForKey:@"accounts"];
    [defaults removeObjectForKey:@"account"];
    [defaults synchronize];

    
    PDKeychainBindings *keychain = [PDKeychainBindings sharedKeychainBindings];

    [keychain removeObjectForKey:@"username"];
    [keychain removeObjectForKey:@"password"];
}
#pragma mark - Actions
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Change the selected background view of the cell.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

-(void) formDidChange{
    NSString * username = [self.form formRowWithTag:@"username"].value;
    NSString *password = [self.form formRowWithTag:@"password"].value;
    BOOL hasCredentials = (password && username && ![username isEqualToString:@""] && ![password isEqualToString:@""]);
    if(self.canCheckCredentials == NO && hasCredentials == YES){
        [self canCheckCredentials:YES];
    }else if (self.hasEnteredCredentials == YES && hasCredentials == NO){
        [self canCheckCredentials:NO];
    }
    self.hasEnteredCredentials = hasCredentials;
}

-(void)canCheckCredentials:(BOOL)can{
    if(self.canCheckCredentials == can){
        return;
    }
    
    XLFormSectionDescriptor *section = [self.form formSectionAtIndex:1];
    XLFormRowDescriptor *row = [self.form formRowWithTag:@"login"];
    if(can == YES){
        [row.cellConfig setObject:[UIColor greenColor] forKey:@"textLabel.textColor"];
        self.navigationItem.rightBarButtonItem = self.saveButton;
        
    }else{
        [row.cellConfig setObject:[UIColor grayColor] forKey:@"textLabel.textColor"];
        self.navigationItem.rightBarButtonItem = nil;
        
    }
    [self.form removeFormRow:row];
    [section addFormRow:row];
    self.canCheckCredentials = can;
}

-(void) hideClient{
    [self.client.view removeFromSuperview];
}

-(void) checkCredentials{
    NSLog(@"check creds");
    if(self.canCheckCredentials == NO){
        return;
    }
    
    __block NSString *username = [self.form formRowWithTag:@"username"].value;
    __block NSString *password = [self.form formRowWithTag:@"password"].value;
    [self showActivityIndicator];
    [self.client loginWithUsername:username password:password success:^(NSArray *accounts){
        self.accounts = accounts;
        [self loadPayees];
    } failure:^(NSError *error){
        [self hideActivityIndicator];
        [self hideClient];
    } progress:nil ];
    
}

-(void)loadPayees{
    [self showActivityIndicator];
    // Assume we've just logged in
    [self.client loadPayees:^(NSArray *payees){
        self.payees = payees;
        [self showDefaultsSection];
        [self hideActivityIndicator];
        [self hideClient];
    } failure:^(NSError *error){
        [self hideActivityIndicator];
        [self hideClient];
    }];
}

-(void)showDefaultsSection{
    [self.form removeFormSectionAtIndex:2];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *payee = [defaults stringForKey:@"payee"];
    NSString *account = [defaults stringForKey:@"account"];
    if (payee == NULL) {
        payee = [self.payees objectAtIndex:0];
    }
    if (account == NULL) {
        account = [self.accounts objectAtIndex:0];
    }
    // Basic Information
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Defaults"];
    [self.form addFormSection:section];
    
    // Account
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"account" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Account"];
    [Settings loadArray: self.accounts intoRow: row withDefault: account];
    [section addFormRow:row];
    
    // Payee
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"payee" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Payee"];
    [Settings loadArray: self.payees intoRow: row withDefault: payee];
    [section addFormRow:row];
}

- (IBAction)savePressed:(UIBarButtonItem *)saveButton
{
    NSString *password = [self.form formRowWithTag:@"password"].value;
    NSString *username = [self.form formRowWithTag:@"username"].value;
    XLFormOptionsObject *payee = [self.form formRowWithTag:@"payee"].value;
    XLFormOptionsObject *account = [self.form formRowWithTag:@"account"].value;
    
    PDKeychainBindings *keychain = [PDKeychainBindings sharedKeychainBindings];
    [keychain setString:username forKey:@"username"];
    [keychain setString:password forKey:@"password"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.payees forKey:@"payees"];
    [defaults setObject:self.accounts forKey:@"accounts"];
    [defaults setValue:payee.formValue forKey:@"payee"];
    [defaults setValue:account.formValue forKey:@"account"];
    [defaults synchronize];
    SettingsNavigationViewController *nc = (SettingsNavigationViewController*)self.navigationController;
    if (nc.settingsDidChange){
        nc.settingsDidChange();
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)done:(id)sender
{
    
}

@end