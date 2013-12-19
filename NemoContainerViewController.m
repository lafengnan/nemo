//
//  NemoContainerViewController.m
//  Nemo
//
//  Created by lafengnan on 13-12-19.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoContainerViewController.h"

@implementation NemoContainerViewController


- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Container"];
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end
