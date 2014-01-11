//
//  HomePageViewController.m
//  Nemo
//
//  Created by lafengnan on 13-12-18.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import "HomePageViewController.h"
#import "NemoObjectViewController.h"
#import "NemoContainerViewController.h"
#import "NemoClient.h"
#import "UIActivityIndicatorView+AFNetworking.h"

@interface HomePageViewController ()


@end

@implementation HomePageViewController
@synthesize userName, passKey, logo;

- (id)init
{
    return [self initWithNibName:@"HomePageViewController" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Callback Blocks

void (^authSuccessed)(UIViewController *hp) = ^(UIViewController *hp){
    
    [[(HomePageViewController *)hp loginIndicator] stopAnimating];  // Stop indicator
    [[UIApplication sharedApplication] endIgnoringInteractionEvents]; // Reactive interaction
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    NemoContainerViewController *containerVc = [[NemoContainerViewController alloc] init];
    NemoObjectViewController *objectVc = [[NemoObjectViewController alloc] init];
    
    UIViewController *settingVc = [[UIViewController alloc] init];
    [[settingVc view] setBackgroundColor:[UIColor brownColor]];
    [[settingVc tabBarItem] setTitle:@"Setting"];
    
    UINavigationController *containerNav = [[UINavigationController alloc] initWithRootViewController:containerVc];
    [containerNav setTitle:@"Container List"];
    
    UINavigationController *objNav = [[UINavigationController alloc] initWithRootViewController:objectVc];
    UINavigationController *setNav = [[UINavigationController alloc] initWithRootViewController:settingVc];
    
    NSArray *viewControllers = [NSArray arrayWithObjects:containerNav, objNav, setNav, nil];
    
    [tabBarController setViewControllers:viewControllers];
    [hp presentViewController:tabBarController animated:YES completion:^(){
        
        NMLog(@"tabBar view controller loaded");
    }];
};

void (^authFailed)(UIViewController *hp, NSError *err) = ^(UIViewController *hp, NSError *err){
    
    [[(HomePageViewController *)hp loginIndicator] stopAnimating];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    
    if ([[err domain] isEqualToString:@"NSURLErrorDomain"]) {
        
        /** If the error description as below:
         *  Error Domain = NSURLErrorDomain
         *  Code = -1001
         *  "The request timed out."
         *  means the service is unavailabe
         */
        alert = [alert initWithTitle:@"Service Unavailabe" message:@"Time out, Please Check Networking Status" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    else if ([[err domain] isEqualToString:@"AFNetworkingErrorDomain"])
    {
        
        NSHTTPURLResponse *response = err.userInfo[@"AFNetworkingOperationFailingURLResponseErrorKey"];
        NMLog(@"HTTP URL Response: %@", response);
        
        NSInteger statusCode = [response statusCode];
        
        NSString *msg = [NSString stringWithString:[err localizedDescription]];
        
        if(statusCode == 401)
            msg = @"Invalid User Name or Password";
        
        alert = [alert initWithTitle:@"Login Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    [alert show];
};

#pragma mark - UI Action

- (IBAction)doLogin:(id)sender
{
    
    NMLog(@"doLogin");
    [NemoClient initialize];
    NemoClient *client = [NemoClient getClient];
    [client setDelegate:self];
    [client setUserName:[userName text]];
    [client setPassWord:[passKey text]];
    [self.loginIndicator startAnimating];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [client authentication:@"tempAuth" success:authSuccessed failure:authFailed];
    
}

// Inplement UITextFieldDeleget

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    // Move textfield frame as per textfied.tag
    // Otherwise the password textfield frame will be covered
    // by popup keyboard
    NSTimeInterval animationDuration = 0.30f;
    CGRect frame = self.view.frame;
    frame.origin.y -=120*(1 + 0.5 * textField.tag);
    frame.size.height +=120*(1 + 0.5 * textField.tag);
    self.view.frame = frame;
    [UIView beginAnimations:@"ResizeView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSTimeInterval animationDuration = 0.30f;
    CGRect frame = self.view.frame;
    frame.origin.y +=120*(1 + 0.5 * textField.tag);
    frame.size.height -=120*(1 + 0.5 * textField.tag);
    self.view.frame = frame;
    //self.view移回原位置
    [UIView beginAnimations:@"ResizeView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
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
    [userName resignFirstResponder];
    [passKey resignFirstResponder];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [userName setDelegate:self];
    [passKey setDelegate:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//    
//    [logo setImage:image];
//    [self dismissViewControllerAnimated:YES completion:^(){}];
//}

@end
