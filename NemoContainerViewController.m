//
//  NemoContainerViewController.m
//  Nemo
//
//  Created by lafengnan on 13-12-19.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoContainerViewController.h"
#import "NemoClient.h"

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
     NSLog(@"Get to Container view");
    // 1. Get client instance
    NemoClient *client = [NemoClient client];
    [client displayClientInfo];
    // 2. display containers
    //[client nemoGetAccount:nil failure:nil];
    
}

@end
