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
@synthesize containerName, isRetention, metaDataTableView, addContainer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    
    
    NSDictionary *metaData = @{@"X-Container-Retention":[NSString stringWithFormat:@"%d", [isRetention isOn]]};
    
   
    NemoContainer *newContainer = [[NemoContainer alloc] initWithContainerName:[containerName text] withMetaData:metaData];
    
    if (client && newContainer) {
        [client nemoPutContainer:newContainer success:^(NemoContainer *newContainer, NSError *error) {
            NMLog(@"Debug: %@ PUT successfully!", newContainer.containerName);
            
            [[client containerList] addObject:newContainer];
             NMLog(@"Debug: Meta: %@", newContainer.metaData);
            
            // Back to root view controller
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } failure:^(NSURLSessionTask *task, NSError *error) {
            NMLog(@"Debug: %@ PUT Failed", newContainer.containerName);
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
//    NSTimeInterval animationDuration = 0.30f;
//    CGRect frame = self.view.frame;
//    frame.origin.y +=120*(1 + 0.5 * textField.tag);
//    frame.size.height -=120*(1 + 0.5 * textField.tag);
//    self.view.frame = frame;
//    //self.view移回原位置
//    [UIView beginAnimations:@"ResizeView" context:nil];
//    [UIView setAnimationDuration:animationDuration];
//    self.view.frame = frame;
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

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //当用户使用自动更正功能，把输入的文字修改为推荐的文字时，就会调用这个方法。
    //这对于想要加入撤销选项的应用程序特别有用
    //可以跟踪字段内所做的最后一次修改，也可以对所有编辑做日志记录,用作审计用途。
    //要防止文字被改变可以返回NO
    //这个方法的参数中有一个NSRange对象，指明了被改变文字的位置，建议修改的文本也在其中
    
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    //返回一个BOOL值指明是否允许根据用户请求清除内容
    //可以设置在特定条件下才允许清除内容
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //之前视图上移了  现在移回来
    //    CGRect frame = self.view.frame;
    //    frame.origin.y +=120;
    //    frame.size.height -=120;
    //    self.view.frame = frame;
    NMLog(@"textfield:%@", textField);
    //返回一个BOOL值，指明是否允许在按下回车键时结束编辑
    //如果允许要调用resignFirstResponder 方法，这回导致结束编辑，而键盘会被收起
    [textField resignFirstResponder];//查一下resign这个单词的意思就明白这个方法了
    
    return YES;
}

// Keyboard hidden if other place is tapped
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [containerName resignFirstResponder];
}





@end
