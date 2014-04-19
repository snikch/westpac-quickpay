//
//  Settings.m
//  Wamex
//
//  Created by Mal Curtis on 19/04/14.
//  Copyright (c) 2014 Mal Curtis. All rights reserved.
//

#import "Settings.h"
#import "GSKeychain.h"

@implementation Settings

+(BOOL) isSetup{
    NSString *username = [[GSKeychain systemKeychain] secretForKey:kUsernameKey];
    if(username == NULL){
        return false;
    }
    NSString *password = [[GSKeychain systemKeychain] secretForKey:kPasswordKey];
    if(password == NULL){
        return false;
    }
    return true;
}


@end
