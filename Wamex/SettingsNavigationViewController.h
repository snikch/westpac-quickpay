//
//  SettingsNavigationViewController.h
//  Wamex
//
//  Created by Mal Curtis on 19/04/14.
//  Copyright (c) 2014 Mal Curtis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsNavigationViewController : UINavigationController
@property (strong, nonatomic) void(^settingsDidChange)(void);
@end
