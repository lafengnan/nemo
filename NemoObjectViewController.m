//
//  NemoObjectViewController.m
//  Nemo
//
//  Created by lafengnan on 13-12-19.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoObjectViewController.h"
#import "NemoClient.h"
#import "NemoObject.h"
#import "NemoContainer.h"

@implementation NemoObjectViewController
@synthesize objectList;

//@synthesize myWebView;

- (id)init
{
 
    return [self initWithObjectList:[[NSMutableArray alloc] init]];
}

- (id)initWithObjectList:(NSMutableArray *)objects
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Object"];
        [tbi setImage:[UIImage imageNamed:@"object_32"]];
        
        // Set Navigation item
        // Set UINavigationItem
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(addNewObject:)];
        [[self navigationItem] setTitle:@"Objects"];
        [[self navigationItem] setRightBarButtonItem:bbi animated:YES];
        
        // Set object list
        [self setObjectList:objects];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NemoClient *client = [NemoClient getClient];
    
    // Clean object list firstly
    [self.objectList count] > 0?[self.objectList removeAllObjects]:nil;
    
    NMLog(@"Debug: %s %d in function:%s", __FILE__, __LINE__, __func__);
    NMLog(@"Debug: client data: %@", client.containerList);
    NMLog(@"Debug: client data: %@", [[client.containerList objectAtIndex:0] containerName]);
    NMLog(@"Debug: client data: %@", [[client.containerList objectAtIndex:0] objectList]);
    
    if (client) {
        for (NemoContainer *eachContainer in client.containerList) {
            [client nemoGetContainer:eachContainer success:^(NemoContainer *container, NSError *jsonError) {
                
                NMLog(@"Debug: %s--%d: %s GET Container Successed!", __FILE__, __LINE__, __func__);
                
                UIActivityIndicatorView  *updateIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [self.tableView addSubview:updateIndicator];
                [updateIndicator startAnimating];
                NMLog(@"Debug: Object List: %@ of container: %@", container.objectList, container.containerName);
                [self.objectList addObjectsFromArray:container.objectList];
                if ([eachContainer.containerName isEqualToString:[[client.containerList lastObject] containerName]]) {
                    NMLog(@"Debug: %s--%d: %s last container: %@ in container List: %@", __FILE__, __LINE__, __func__,
                          eachContainer, client.containerList);
                    NMLog(@"Debug: %s--%d: %s total Object List: %@", __FILE__, __LINE__, __func__, self.objectList);
                    [self.tableView reloadData];
                }
                [updateIndicator stopAnimating];
                
            } failure:^(NSURLSessionTask *task, NSError *error) {
                ;
            }];
        }
    }
    
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view1 =
        [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        view1.delegate = self;
        // Add self defined view to tablview
        [self.tableView addSubview:view1];
        _refreshHeaderView = view1;
    }
    [_refreshHeaderView refreshLastUpdatedDate];

}

//- (void)loadView
//{
//    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
//    UIWebView *wv = [[UIWebView alloc] initWithFrame:screenFrame];
//    [wv setScalesPageToFit:YES];
//    
//    [self setView:wv];
//}
//
//- (UIWebView *)myWebView
//{
//    return (UIWebView *)[self view];
//}


#pragma mare - TableViewController Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NMLog(@"Debug: %s--%d: %s\n, Display %u lines", __FILE__, __LINE__, __func__,(unsigned int)[self.objectList count]);
    return [self.objectList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ObjectList"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ObjectList"];
        [cell.imageView setImage:[UIImage imageNamed:@"object_32.png"]];
    }
    
    NemoObject *object = [self.objectList objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:object.objectName];
    
    
    /** Set date format and displays it **/
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[object.metaData[@"X-Timestamp"] doubleValue]];
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
    NemoClient *client = [NemoClient getClient];
    NemoObject *object = [self.objectList objectAtIndex:[indexPath row]];
    NemoContainer *container = [object masterContainer];
    
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        /* Send DELETE operation to Swift */
        [client nemoDeleteObject:object fromContainer:container success:^(NemoContainer *container, NemoObject *object, NSError *error) {
            NMLog(@"Debug: %s %d %s", __FILE__, __LINE__, __func__);
            NMLog(@"Debug: %@ is deleted form %@", object.objectName, container.containerName);
            [self.objectList removeObject:object];
            [container.objectList removeObject:object];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation: UITableViewRowAnimationFade];
            
        } failure:^(NSURLSessionTask *task, NSError *error) {
            /** Object could not be deleted if it has already been deleted
             *  by other client operations.
             */
            if ([(NSHTTPURLResponse *)[task response] statusCode] == 404) {
                NMLog(@"Debug: The object: %@ is not existing in container: %@", object.objectName, container.containerName);
                NSString *msg = [NSString stringWithFormat:@"%@ is not existing!", object.objectName];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Failed!" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
        }];
        
    }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        
        NemoObject *newObject = [[NemoObject alloc] initWithObjectName:nil fileExtension:@"file" andMetaData:nil];
        [self.objectList addObject:newObject];
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
//    NemoContainerDetailViewController *containerDetailVc = [[NemoContainerDetailViewController alloc] init];
//    
//    NemoContainer *container = [containerList objectAtIndex:[indexPath row]];
//    
//    [containerDetailVc setContainer:container];
//    
//    [self.navigationController pushViewController:containerDetailVc animated:YES];
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark -  Data Source Methods

- (IBAction)addNewObject:(id)sender
{
//   NemoNewContainerViewController *newVc = [[NemoNewContainerViewController alloc] init];
//   [self.navigationController pushViewController:newVc animated:YES];
}


- (void)updateObjectList
{
    
    /** Data will be updated while pulling down
     *  A new container list will be displayed
     */
    NemoClient *client = [NemoClient getClient];
    
    /** To updat object list, client needs to update as
     *  1. GET account 
     *  2. HEAD all containers
     *  3. GET the container to update
     */
    if (client) {
        NMLog(@"Debug: %s Line %d in function: %s\n", __FILE__, __LINE__, __func__);
        NMLog(@"Debug: object list: %@", self.objectList);
        [self.objectList removeAllObjects]; // clean object list firstly
        
        [client nemoGetAccount:^(NSArray *containers, NSError *jsonError) {
            NMLog(@"Debug: GET Account successful");
            /* Do HEAD operation here to display cell detail lable */
            for (NemoContainer *eachContainer in containers) {
                [client nemoHeadContainer:eachContainer success:^(NemoContainer *container, NSError *jsonError) {
                    NMLog(@"container: %@", container.containerName);
                    NMLog(@"tableviw did load--->HEAD: %@", container.metaData);
                    
                    // Do GET Container Here
                    NMLog(@"Debug: %s -- line:%d in function: %s\n, container: %@", __FILE__, __LINE__, __func__, eachContainer.containerName);
                    NMLog(@"Debug: Object List: %@", eachContainer.objectList);
                    [client nemoGetContainer:eachContainer success:^(NemoContainer *container, NSError *jsonError) {
                        
                        [self.objectList addObjectsFromArray:container.objectList];
                        if ([[client.containerList lastObject] isEqualToContainer:container]) {
                            [self.tableView reloadData];
                        }
                    } failure:^(NSURLSessionTask *task, NSError *error) {
                        ;
                    }];
                    
                } failure:^(NSURLSessionTask *task, NSError *error) {
                    ;
                }];
                
            }

        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            ;
        }];
        
    }
    
    _reloading = YES;
}

- (void)doneUpdatingObjectList
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
    [self updateObjectList];
    [self performSelector:@selector(doneUpdatingObjectList) withObject:nil afterDelay:3.0];
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
