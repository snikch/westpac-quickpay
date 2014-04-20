//
//  Settings.h
//  Wamex
//
//  Created by Mal Curtis on 19/04/14.
//  Copyright (c) 2014 Mal Curtis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XLForm.h>

@interface Settings : NSObject

+(BOOL) isSetup;

+(NSString*) username;
+(NSString*) password;

+(void) loadArray: (NSArray *)array
          intoRow: (XLFormRowDescriptor*)row
      withDefault: (NSString*) defaultValue;
@end



