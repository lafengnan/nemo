//
//  NemoObjectDetailViewController.m
//  Nemo
//
//  Created by lafengnan on 14-1-22.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoObjectDetailViewController.h"

@implementation NemoObjectDetailViewController

@synthesize objInstance;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}


@end
