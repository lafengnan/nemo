//
//  NemoContainerSelectorViewController.m
//  Nemo
//
//  Created by lafengnan on 14-1-22.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoContainerSelectorViewController.h"
#import "NemoContainer.h"

@interface NemoContainerSelectorViewController ()

@end

@implementation NemoContainerSelectorViewController
@synthesize containerList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NMLog(@"Debug: %s %d %s", __FILE__, __LINE__,__func__);

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Custom initialization
    // Set UINavigationItem
    
    [[self navigationItem] setTitle:@"Containers"];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    NMLog(@"Debug: %@ navigation Item: %@", self, self.navigationItem);
}

//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    
//    [self.navigationController popToRootViewControllerAnimated:animated];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NMLog(@"Debug: %s %d %s", __FILE__, __LINE__, __func__);
    NMLog(@"Debug: display %lu lines", (unsigned long)self.containerList.count);
    return [self.containerList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContainerSelector"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContainerSelector"];
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
