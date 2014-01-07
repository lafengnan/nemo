//
//  NemoContainerViewController.m
//  Nemo
//
//  Created by lafengnan on 13-12-19.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoContainerViewController.h"
#import "NemoClient.h"
#import "NemoContainerDetailViewController.h"
#import "NemoContainer.h"

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
        
        // Set tabbar
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Container"];
        [tbi setImage:[UIImage imageNamed:@"container_item_32"]];
        self.containerList = [NSMutableArray arrayWithArray:containers];
        // Set UINavigationItem
        [[self navigationItem] setTitle:@"My Containers"];
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
//    dispatch_queue_t nemoGetAccountQueue = dispatch_queue_create("com.get.account.nemo", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_async(nemoGetAccountQueue, ^{
        [client nemoGetAccount:^(NSArray *containers, NSError *jsonError) {
            /* Copy container list here */
            [self setContainerList:(NSMutableArray *)containers];
            
            /* Do HEAD operation here to display cell detail lable */
            for (NemoContainer *con in self.containerList) {
                [client nemoHeadContainer:con.containerName success:^(NSString *containerName, NSError *jsonError) {
                    NSLog(@"container: %@", containerName);
                    NSLog(@"tableviw did load--->HEAD: %@", con.metaData);
                    [self.tableView reloadData];
                    
                } failure:^(NSURLSessionTask *task, NSError *error) {
                    ;
                }];

            }
            
            [self.tableView reloadData];
            
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
//    });
    
    

    
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view1 =
        [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        view1.delegate = self;
        [self.tableView addSubview:view1];//这里要把view加到自己定义的tableview上
        _refreshHeaderView = view1;
    }
    [_refreshHeaderView refreshLastUpdatedDate];

}

#pragma mare - TableViewController Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"display %u lines", (unsigned int)[self.containerList count]);
    return [self.containerList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContainerList"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContainerList"];
        [cell.imageView setImage:[UIImage imageNamed:@"container_32.png"]];
    }
    
    /** detailTextLabel will displays meta data of the 
     *  container, so that a head operation needs to be 
     *  performed here.
     */
    NemoContainer *container = [containerList objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:container.containerName];
    
    /** Set date format and displays it **/
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[container.metaData[@"X-Timestamp"] doubleValue]];
    NSString *formattedDateString = [@"Last Update: " stringByAppendingString:[dateFormatter stringFromDate:date]];

    [[cell detailTextLabel] setText:formattedDateString];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    
    return cell;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [NSString stringWithFormat:@"Container List"];
//}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

/** Delete the container while left moving tableviewcell
 *  Container could not be delete unless there is no object
 *  in the container 
 */

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.containerList removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
//{
//    
//
//}

/** If one row is selected the detail view pops from right
 *  Using a navigationcontroller to controll NemoContainerDetailViewController
 *  and the root controller
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NemoContainerDetailViewController *containerDetailVc = [[NemoContainerDetailViewController alloc] init];
    
    NemoContainer *container = [containerList objectAtIndex:[indexPath row]];
    
    [containerDetailVc setContainer:container];
    
    [self.navigationController pushViewController:containerDetailVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        [self setContainerList:(NSMutableArray *)containers];
        
        for (NemoContainer *con in self.containerList) {
            [client nemoHeadContainer:con.containerName success:^(NSString *containerName, NSError *jsonError) {
            [self.tableView reloadData];
                
            } failure:^(NSURLSessionTask *task, NSError *error) {
                ;
            }];
        }

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
