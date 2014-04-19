//
//  FlipsideViewController.m
//  Wamex
//
//  Created by Mal Curtis on 19/04/14.
//  Copyright (c) 2014 Mal Curtis. All rights reserved.
//

#import "FlipsideViewController.h"
#import "Settings.h"

@interface FlipsideViewController ()

@end

@implementation FlipsideViewController

-(id)init{
    self.hasEnteredCredentials = NO;
    self.client = [[WebClient alloc]init];

    
    // Do any additional setup after loading the view, typically from a nib.
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"Settings"];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // Title
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"username" rowType:XLFormRowDescriptorTypeText title:@"Customer ID"];
    [section addFormRow:row];
    
    // Location
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"password" rowType:XLFormRowDescriptorTypePassword title:@"Password"];
    [section addFormRow:row];
    
    // Add the 'check' button
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // Title
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"login" rowType:XLFormRowDescriptorTypeButton title:@"Check Credentials"];
    [row.cellConfig setObject:[UIColor grayColor] forKey:@"textLabel.textColor"];

    [section addFormRow:row];

    
    self = [self initWithForm:form formMode:XLFormModeCreate showCancelButton:[Settings isSetup] showSaveButton:NO showDeleteButton:NO deleteButtonCaption:nil];
    
    self.showNetworkReachability = YES;
    self.form.assignFirstResponderOnShow = YES;
    [self formDidChange];
    
    return self;
}

#pragma mark - XLFormDescriptorDelegate
-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    NSLog(@"Value did change");
    [self formDidChange];
    
}
-(void)didSelectFormRow:(XLFormRowDescriptor *)formRow{
    [super didSelectFormRow:formRow];
    if([formRow.tag isEqualToString:@"login"]){
        [self checkCredentials];
    }
    
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
    NSLog(@"Has creds? %@", hasCredentials ? @"YES" : @"NO");
    if(self.canCheckCredentials == NO && hasCredentials == YES){
        [self canCheckCredentials:YES];
    }else if (self.hasEnteredCredentials == YES && hasCredentials == NO){
        
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
    }else{
        [row.cellConfig setObject:[UIColor grayColor] forKey:@"textLabel.textColor"];
    }
    [self.form removeFormRow:row];
    [section addFormRow:row];
    self.canCheckCredentials = can;
}
-(void) checkCredentials{
    NSLog(@"check creds");
    if(self.canCheckCredentials == NO){
        return;
    }
    
    NSString * username = [self.form formRowWithTag:@"username"].value;
    NSString *password = [self.form formRowWithTag:@"password"].value;
    [self showActivityIndicator];
    [self.client loginWithUsername:username password:password success:^{
        [self hideActivityIndicator];
        [self showDefaultsSection];
    } failure:^(NSError *error){
        [self showDefaultsSection];
        [self hideActivityIndicator];
        [self.client.view removeFromSuperview];
        
    } progress:nil ];
    
    CGRect pos = self.view.bounds;
    pos.origin.y -= pos.size.height / 3;
    pos.origin.y += pos.size.height;
    self.client.view.frame = pos;
    [self.view addSubview:self.client.view];

}
-(void)showDefaultsSection{
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    // Basic Information
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Defaults"];
    [self.form addFormSection:section];
    
    // Payee
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"payee" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Payee"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Option 1"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Option 2"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Option 3"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Option 4"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Option 5"]
                            ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Option 2"];
    [section addFormRow:row];
    
    // Account
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"account" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Account"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Option 1"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Option 2"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Option 3"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Option 4"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Option 5"]
                            ];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Option 2"];
    [section addFormRow:row];
}

- (IBAction)savePressed:(UIBarButtonItem *)saveButton
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)done:(id)sender
{
    
}

@end
