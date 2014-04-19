//
//  Settings.m
//  Wamex
//
//  Created by Mal Curtis on 19/04/14.
//  Copyright (c) 2014 Mal Curtis. All rights reserved.
//

#import "Settings.h"
#import <PDKeychainBindings.h>

@implementation Settings

+(BOOL) isSetup{
    PDKeychainBindings *keychain = [PDKeychainBindings sharedKeychainBindings];
    NSString *username = [keychain stringForKey:@"username"];
    if(username == NULL){
        return false;
    }
    NSString *password = [keychain stringForKey:@"password"];
    if(password == NULL){
        return false;
    }
    return true;
}


@end
