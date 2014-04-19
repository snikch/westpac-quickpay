//
//  SettingsNavigationViewController.m
//  Wamex
//
//  Created by Mal Curtis on 19/04/14.
//  Copyright (c) 2014 Mal Curtis. All rights reserved.
//

#import "SettingsNavigationViewController.h"
#import "FlipsideViewController.h"

@implementation SettingsNavigationViewController

-(id)init
{
    self = [super initWithRootViewController:[[FlipsideViewController alloc] init]];
    return  self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setTintColor:[UIColor greenColor]];
}

@end
