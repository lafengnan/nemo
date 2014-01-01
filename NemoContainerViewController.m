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
   [client nemoGetAccount:^(NSArray *containers, NSError *jsonError) {
       
       NSLog(@"contaiers: %@", containers);
       
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
    
}

@end
