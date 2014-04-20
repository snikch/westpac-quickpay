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
    if([self username] == NULL){
        return false;
    }
    if([self password] == NULL){
        return false;
    }
    return true;
}

+(NSString*)username{
    PDKeychainBindings *keychain = [PDKeychainBindings sharedKeychainBindings];
    return [keychain stringForKey:@"username"];
}

+(NSString*)password{
    PDKeychainBindings *keychain = [PDKeychainBindings sharedKeychainBindings];
    return [keychain stringForKey:@"password"];
}

+(void) loadArray: (NSArray *)array
          intoRow: (XLFormRowDescriptor*)row
      withDefault: (NSString *)defaultValue
{
    __block NSMutableArray *arrayOptions = @[].mutableCopy;
    [array enumerateObjectsUsingBlock:^(NSString * object, NSUInteger idx, BOOL *stop) {
        XLFormOptionsObject *option = [XLFormOptionsObject formOptionsObjectWithValue:object displayText:object];
        [arrayOptions addObject:option];
        if ([object isEqualToString:defaultValue]){
            row.value = option;
        }
    }];
    
    row.selectorOptions = arrayOptions;
    
    if (!row.value) {
        row.value = [arrayOptions objectAtIndex:0];
    }
}


@end
