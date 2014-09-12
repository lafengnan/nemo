//
//  NemoNewContainerViewController.m
//  Nemo
//
//  Created by lafengnan on 14-1-11.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoNewContainerViewController.h"
#import "NemoContainer.h"
#import "NemoClient.h"

@interface NemoNewContainerViewController ()

@end

@implementation NemoNewContainerViewController
@synthesize containerName, isRetention, willAddMetaData, metaDataTableView, nemoNewContainer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Init container
        [self setNemoNewContainer:[[NemoContainer alloc] initWithContainerName:@"test" withMetaData:nil]];
        self.nemoNewContainer.metaData = [[NSMutableDictionary alloc] initWithDictionary:@{@"X-Container-Meta-Test": @"test"}];
        
        // Custom initialization
        // Set UINavigationItem
        UIBarButtonItem *rbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                             target:self
                                                                             action:@selector(addNewContainer:)];
        UIBarButtonItem *lbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                             target:self
                                                                             action:@selector(viewWillDisappear:)];
        [[self navigationItem] setTitle:@"New Container"];
        [[self navigationItem] setRightBarButtonItem:rbbi animated:YES];
        [[self navigationItem] setLeftBarButtonItem:lbbi animated:YES];
       
    }
    return self;
}

#pragma mark - UINavigationController Back

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Back to root view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (IBAction)addNewContainer:(id)sender
{
    __block NemoClient *client = [NemoClient getClient];
    
    
    NSDictionary *metaData = @{@"X-Container-Meta-Retention":[NSString stringWithFormat:@"%d", [isRetention isOn]]};
    
    [self.nemoNewContainer setContainerName:[containerName text]];
    if (!self.nemoNewContainer.metaData)
        [self.nemoNewContainer setMetaData:(NSMutableDictionary *)metaData];
    else
        [self.nemoNewContainer.metaData setValue:[NSString stringWithFormat:@"%d",[isRetention isOn]]
                                          forKey:@"X-Container-Meta-Retention"];
    
    if (client && self.nemoNewContainer) {
        [client nemoPutContainer:self.nemoNewContainer success:^(NemoContainer *newContainer, NSError *error) {
            NMLog(@"Debug: %@ PUT successfully!", newContainer.containerName);
            
            [[client containerList] addObject:newContainer];
             NMLog(@"Debug: Meta: %@", newContainer.metaData);
            
            // Back to root view controller
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } failure:^(NSURLSessionTask *task, NSError *error) {
            NMLog(@"Debug: %@ PUT Failed", self.nemoNewContainer.containerName);
            NMLog(@"Debug: Error: %@", error.localizedDescription);
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
    
}

//- (IBAction)canCellAddNewContainer:(id)sender
//{
//    
//}

#pragma mark - UI methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [containerName setDelegate:self];
    [metaDataTableView setDelegate:self];
    [metaDataTableView setDataSource:self];
    [isRetention setOn:NO animated:YES];
    [willAddMetaData setOn:YES animated:YES];
    [metaDataTableView setEditing:YES animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFiledDelegate


// Inplement UITextFieldDeleget

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    [textField setTextColor:[UIColor blackColor]];
    [UIView commitAnimations];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

    [UIView commitAnimations];
    [textField resignFirstResponder];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{

    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NMLog(@"textfield:%@", textField);
    [textField resignFirstResponder];
    
    return YES;
}

// Keyboard hidden if other place is tapped
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [containerName resignFirstResponder];
}

#pragma mark - UITableView Methods


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Meta Data"];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.nemoNewContainer.metaData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *metaData = [self.nemoNewContainer metaData];
    NSArray *metaDataKeys = [metaData allKeys];
    NMLog(@"Debug: meta Data: %@", metaData);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MetaData"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MetaData"];
    }
    
    [[cell textLabel] setText:@"Add Meta Data"];
    [[cell textLabel] setTextColor:[UIColor colorWithRed:50.0f/256.0f green:100.0f/256.0f blue:1.0f alpha:1.0f]];
    [[cell textLabel] setFont:[UIFont fontWithName:@"Arial-Bold" size:10.0]];
    
    /** Self define new accessory type **/
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    return cell;
}

/** If one row is selected the detail view pops from right
 *  Using a navigationcontroller to controll NemoContainerDetailViewController
 *  and the root controller
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleInsert;
}

/** Delete the container while left moving tableviewcell
 *  Container could not be delete unless there is no object
 *  in the container
 */

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableArray *metaDataKeys = [NSMutableArray arrayWithArray:[self.nemoNewContainer.metaData allKeys]];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.nemoNewContainer.metaData removeObjectForKey:[metaDataKeys objectAtIndex:[indexPath row]]];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation: UITableViewRowAnimationFade];
        
    }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        
        NMLog(@"Debug: Line %d: %s in %s", __LINE__, __func__, __FILE__);
        
        NSString *key = @"X-Container-Meta-Test1";
        // Copy the original meta data dictionary for judging if new row
        // needs to be inserted after set meta data
        NSMutableDictionary *tempMeta = [self.nemoNewContainer.metaData copy];
        
        if (self.nemoNewContainer.metaData) {
            [self.nemoNewContainer.metaData setObject:@"invalid" forKey:key];
        }
        // If the key has been in meta data dictionary, the insertion becomes update
        // So do not inser a new row here. Because the number of row in section is
        // equal to the count of container.MetaData key-value paris
        if (![tempMeta valueForKey:key])
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    
}

@end
