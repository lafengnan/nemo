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
@synthesize containerList;


- (id)init
{
    NSArray *containers = [[NSArray alloc] init];
    return [self initContainerList:containers];
}

- (id)initContainerList:(NSArray *)containers
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Container"];
        self.containerList = [NSArray arrayWithArray:containers];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     NSLog(@"table view did load");
    // 1. Get client instance
    NemoClient *client = [NemoClient client];
    //[client displayClientInfo];
    // 2. display containers
    dispatch_queue_t nemoGetAccountQueue = dispatch_queue_create("com.get.account.nemo", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(nemoGetAccountQueue, ^{
        [client nemoGetAccount:^(NSArray *containers, NSError *jsonError) {
            /* Copy container list here */
            [self setContainerList:containers];
            [[self tableView] reloadData];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            NSLog(@"error %@", error);
            void (^displayTask)(NSURLSessionDataTask *t) = ^(NSURLSessionDataTask *task)
            {
                NSLog(@"Get Token Successful from %@", client.storageUrl);
                NSLog(@"countOfBytesExpectedToReceive:  %lld", [task countOfBytesExpectedToReceive]);
                NSLog(@"countOfBytesReceived: %lld", [task countOfBytesReceived]);
                NSLog(@"countOfBytesExpectedToSend:  %lld", [task countOfBytesExpectedToSend]);
                NSLog(@"countOfBytesSent: %lld", [task countOfBytesSent]);
                NSLog(@"request--->header: %@", [[task currentRequest] allHTTPHeaderFields]);
                NSLog(@"request--->method: %@", [[task currentRequest] HTTPMethod]);
                
                NSLog(@"response--->%@", [task response]);
                NSLog(@"account: %@", [[[client storageUrl] componentsSeparatedByString:@"/"] lastObject]);
            };
            
            displayTask(task);
        }];
    });

}

#pragma mare - TableViewController Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"display %u lines", [self.containerList count]);
    return [self.containerList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    NSString *container = [containerList objectAtIndex:[indexPath row]];
  
    [[cell textLabel] setText:container];
    
    return cell;
}

@end
