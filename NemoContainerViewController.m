//
//  NemoContainerViewController.m
//  Nemo
//
//  Created by lafengnan on 13-12-19.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoContainerViewController.h"
#import "NemoContainerDetailViewController.h"
#import "NemoNewContainerViewController.h"

#import "NemoClient.h"
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
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(addNewContainer:)];
        [[self navigationItem] setTitle:@"My Containers"];
        [[self navigationItem] setRightBarButtonItem:bbi animated:YES];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    /** Draw activity indicator view for HEAD operation **/
    CGRect frame = CGRectMake(150.0f, 220.0f, 37.0f, 37.0f);
    
    UIActivityIndicatorView  *updateIndicator = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    [updateIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.tableView addSubview:updateIndicator];
    [updateIndicator startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    // 1. Get client instance
    NemoClient *client = [NemoClient getClient];
    // 2. display containers
    [client nemoGetAccount:^(NSArray *containers, NSError *jsonError) {
        /* Copy container list here */
        [self setContainerList:[(NSMutableArray *)containers mutableCopy]];
        NMLog(@"Debug: %s %d %s", __FILE__, __LINE__, __func__);
        NMLog(@"Debug: container list is : %@", containerList);
        NMLog(@"Debug: container list of client is : %@", client.containerList);
        /* Do HEAD operation here to display cell detail lable */
        
        /** 2014.1.21 notes:
         *  Because multithreads are running concurrently, the last container
         *  maybe returned ahead of other ones, and makes table reload data
         *  uncorrectly, this need to fix. And the same issue exists in the 
         *  same method of NemoObjectViewController.m
         */
        for (NemoContainer *con in self.containerList) {
            [client nemoHeadContainer:con success:^(NemoContainer *container, NSError *jsonError) {
                NMLog(@"Debug: HEAD %@ successfully!", con.containerName);
                NMLog(@"Debug: HEAD Meta Data: %@", con.metaData);
                NMLog(@"Debug: Currenty Container is: %@", con);
                NMLog(@"Debug: Last container is %@", containerList.lastObject);
                
                if ([[client.containerList lastObject] isEqualToContainer:con]) {
                    [updateIndicator stopAnimating];
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                    [self.tableView reloadData];
                }
                
            } failure:^(NSURLSessionTask *task, NSError *error) {
                ;
            }];
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NMLog(@"error %@", error);
        void (^displayTask)(NSURLSessionDataTask *t) = ^(NSURLSessionDataTask *task)
        {
            NMLog(@"Get Token Successful from %@", client.storageUrl);
            NMLog(@"countOfBytesExpectedToReceive:  %lld", [task countOfBytesExpectedToReceive]);
            NMLog(@"countOfBytesReceived: %lld", [task countOfBytesReceived]);
            NMLog(@"countOfBytesExpectedToSend:  %lld", [task countOfBytesExpectedToSend]);
            NMLog(@"countOfBytesSent: %lld", [task countOfBytesSent]);
            NMLog(@"request--->header: %@", [[task currentRequest] allHTTPHeaderFields]);
            NMLog(@"request--->method: %@", [[task currentRequest] HTTPMethod]);
            
            NMLog(@"response--->%@", [task response]);
            NMLog(@"account: %@", [[[client storageUrl] componentsSeparatedByString:@"/"] lastObject]);
        };
        
        displayTask(task);
    }];

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NMLog(@"table view did load");
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
    NMLog(@"display %u lines", (unsigned int)[self.containerList count]);
    return [self.containerList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContainerList"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContainerList"];
        [cell.imageView setImage:[UIImage imageNamed:@"container_32.png"]];
    }
    

    NemoContainer *container = [containerList objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:container.containerName];
    
    
    /** Set date format and displays it **/
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[container.metaData[@"X-Timestamp"] doubleValue]];
    NSString *formattedDateString = [@"Last Update: " stringByAppendingString:[dateFormatter stringFromDate:date]];

    [[cell detailTextLabel] setText:formattedDateString];
    [[cell detailTextLabel] setTextColor:[UIColor colorWithRed:50.0f/256.0f green:100.0f/256.0f blue:1.0f alpha:1.0f]];
    
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
    
    /* Get client and container which willbe edit */
    __block NemoClient *client = [NemoClient getClient];
    __block NemoContainer *container = self.containerList[indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        /* Send DELETE operation to Swift */
        [client nemoDeleteContainer:container success:^(NemoContainer *container, NSError *jsonError) {
            
            NMLog(@"Debug: Container: %@ has deleted!", container.containerName);
            
            /* Remove the container in container list and update UI */
            [self.containerList removeObjectAtIndex:indexPath.row];
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation: UITableViewRowAnimationFade];
            ;
        } failure:^(NSURLSessionTask *task, NSError *error) {
            /* Container could not be deleted if it has objects
             * status code 409 returned if delete an nonempty container
             */
            if ([(NSHTTPURLResponse *)[task response] statusCode] == 409) {
                NMLog(@"Debug: Conflict happens while deleting %@", container.containerName);
                NSString *msg = [NSString stringWithFormat:@"%@ is not empty, Deletion is forbidden!", container.containerName];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Failed!" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
        }];
        
    }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        
        NemoContainer *newContainer = [[NemoContainer alloc] initWithContainerName:@"new" withMetaData:nil];
        [containerList addObject:newContainer];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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



#pragma mark -  Data Source Methods

- (IBAction)addNewContainer:(id)sender
{
    NemoNewContainerViewController *newVc = [[NemoNewContainerViewController alloc] init];
    [self.navigationController pushViewController:newVc animated:YES];
}


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
            [client nemoHeadContainer:con success:^(NemoContainer *container, NSError *jsonError) {
                
                // Reload Data after last container HEAD operation completes
                if ([con isEqualToContainer:containerList.lastObject]) {
                    [self.tableView reloadData];
                }
                
            } failure:^(NSURLSessionTask *task, NSError *error) {
                ;
            }];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NMLog(@"error %@", error);
        void (^displayTask)(NSURLSessionDataTask *t) = ^(NSURLSessionDataTask *task)
        {
            NMLog(@"Get Token Successful from %@", client.storageUrl);
            NMLog(@"countOfBytesExpectedToReceive:  %lld", [task countOfBytesExpectedToReceive]);
            NMLog(@"countOfBytesReceived: %lld", [task countOfBytesReceived]);
            NMLog(@"countOfBytesExpectedToSend:  %lld", [task countOfBytesExpectedToSend]);
            NMLog(@"countOfBytesSent: %lld", [task countOfBytesSent]);
            NMLog(@"request--->header: %@", [[task currentRequest] allHTTPHeaderFields]);
            NMLog(@"request--->method: %@", [[task currentRequest] HTTPMethod]);
            
            NMLog(@"response--->%@", [task response]);
            NMLog(@"account: %@", [[[client storageUrl] componentsSeparatedByString:@"/"] lastObject]);
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
