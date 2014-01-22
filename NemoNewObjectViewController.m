//
//  NemoNewObjectViewController.m
//  Nemo
//
//  Created by lafengnan on 14-1-22.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoNewObjectViewController.h"
#import "NemoContainerSelectorViewController.h"
#import "NemoContainer.h"
#import "NemoObject.h"
#import "NemoClient.h"

@interface NemoNewObjectViewController ()

@end

@implementation NemoNewObjectViewController
@synthesize nemoNewObject, objectName, containerName, isCopy;

#pragma mark - initializer

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // Lazy init object while adding new object
        [self setNemoNewObject:nil];
        
        // Custom initialization
        // Set UINavigationItem
        UIBarButtonItem *rbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self
                                                                              action:@selector(addNewObject:)];
        UIBarButtonItem *lbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                              target:self
                                                                              action:@selector(viewWillDisappear:)];
        [[self navigationItem] setTitle:@"New Object"];
        [[self navigationItem] setRightBarButtonItem:rbbi animated:YES];
        [[self navigationItem] setLeftBarButtonItem:lbbi animated:YES];
    }
    return self;
}

#pragma mark - view methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.objectName setDelegate:self];
    [self.containerName setDelegate:self];
    [self.isCopy setOn:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.isCopy isOn]) {
       
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - IBAction

- (IBAction)uploadFile:(UIButton *)sender {
}

- (IBAction)copyFromExistingContainer:(id)sender {
    
    NemoClient *client = [NemoClient getClient];
    NSMutableArray *sourceContainerList = [[NSMutableArray alloc] init];
    if (client && sourceContainerList) {
        
        sourceContainerList = [[client containerList] mutableCopy];
    }

    NemoContainerSelectorViewController *containerListVc = [[NemoContainerSelectorViewController alloc] init];
    [containerListVc setContainerList:[sourceContainerList mutableCopy]];
    NMLog(@"Debug: %s %d %s", __FILE__, __LINE__, __func__);
    NMLog(@"Debug: client: %@", client);
    NMLog(@"Debug: container List: %@", client.containerList);
    NMLog(@"Debug: NavigationController before push: %@", self.navigationController.viewControllers);
    
    [self.navigationController pushViewController:containerListVc animated:YES];
     NMLog(@"Debug: NavigationController after push: %@", self.navigationController.viewControllers);
    
//    CGRect frame = CGRectMake(34.0f, 250.0f, 200.0f, 100.0f);
//    
//    UITableView *subView = [[UITableView alloc] initWithFrame:frame];
//    [self.view addSubview:subView];
//    
//    // Redraw the view
//    [self.view setNeedsDisplay];
}

- (IBAction)addNewObject:(id)sender
{
    NemoClient *client = [NemoClient getClient];
    if (client) {
        // Lazy initialize object here
        self.nemoNewObject = !self.nemoNewObject?[[NemoObject alloc] init]:self.nemoNewObject;
        if (self.nemoNewObject) {
            [self.nemoNewObject setObjectName:[self.objectName text]];
            [self.container setContainerName:[self.containerName text]];
        }
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
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
@end
