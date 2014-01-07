//
//  NemoContainerDetailViewController.m
//  Nemo
//
//  Created by lafengnan on 14-1-6.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoContainerDetailViewController.h"
#import "NemoContainer.h"
#import "NemoClient.h"

@interface NemoContainerDetailViewController ()

@end

@implementation NemoContainerDetailViewController
@synthesize bytesUsed, createTimeStamp, objectCount, containerImage, container;

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
    
    NSLog(@"view will appear");
    
    NemoClient *client = [NemoClient getClient];
    
    [client nemoHeadContainer:[self.container containerName] success:^(NSString *containerName, NSError *jsonError) {
        
        /** Set date format and displays it **/
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[container.metaData[@"X-Timestamp"] doubleValue]];
        NSString *formattedDateString = [dateFormatter stringFromDate:date];
        [self.createTimeStamp setText:formattedDateString];
        
        [self.objectCount setText:container.metaData[@"X-Container-Object-Count"]];
        
        
        [self.bytesUsed setText:[self.container.metaData[@"X-Container-Bytes-Used"] stringByAppendingString:@"Bytes"]];

        [[self navigationItem] setTitle:self.container.containerName];
        [self.view setNeedsDisplay];
    } failure:^(NSURLSessionTask *task, NSError *error) {
        ;
    }];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    /** After view loaded, app needs to update container meta data here
     *  So controller will invoke nemoHeadContainer here to display the 
     *  meta data of a specified container 
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
