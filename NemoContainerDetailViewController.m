//
//  NemoContainerDetailViewController.m
//  Nemo
//
//  Created by lafengnan on 14-1-6.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoContainerDetailViewController.h"
#import "NemoContainer.h"

@interface NemoContainerDetailViewController ()

@end

@implementation NemoContainerDetailViewController
@synthesize containerName, createTimeStamp, objectCount, containerImage, container;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [containerName setText:[container containerName]];
    [createTimeStamp setText:[[NSDate date] description]];
    [objectCount setText:@"1"];
    [[self navigationItem] setTitle:self.container.containerName];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"detail pushed");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
