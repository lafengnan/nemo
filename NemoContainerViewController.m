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
    return [self initWithContainerList:containers];
}

- (id)initWithContainerList:(NSArray *)containers
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
    NemoClient *client = [NemoClient getClient];
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
    
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view1 =
        [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        //注意下拉框的位置描述！要把tableViewImage换成自己定义的tableview！
        view1.delegate = self;
        [self.tableView addSubview:view1];//这里要把view加到自己定义的tableview上
        _refreshHeaderView = view1;
    }
    [_refreshHeaderView refreshLastUpdatedDate];

}

#pragma mare - TableViewController Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"display %u lines", [self.containerList count]);
    return [self.containerList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContainerList"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContainerList"];
    }
    
    NSString *container = [containerList objectAtIndex:[indexPath row]];
  
    [[cell textLabel] setText:container];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Container List"];
}

#pragma mark -  Data Source Loading/Reloading methods
- (void)updateContainerList
{
    
    /** Data will be updated while pulling down
     *  A new container list will be displayed
     */
    NemoClient *client = [NemoClient getClient];
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

    
    _reloading = YES;
}

- (void)doneUpdatingContainerList
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self updateContainerList];
    [self performSelector:@selector(doneUpdatingContainerList) withObject:nil afterDelay:3.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return  _reloading;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}
@end
