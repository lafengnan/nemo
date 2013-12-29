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

- (IBAction)doLogin:(id)sender
{
    
    NSLog(@"doLogin");
    NemoClient *client = [[NemoClient alloc] init];
    [client setUserName:[userName text]];
    [client setPassWord:[passKey text]];
    
    [client authentication:@"tempAuth"];
    
    
    if ([client userName] &&
        [client passWord]) {
        NSLog(@"UserName: %@ PassWord: %@", client.userName, client.passWord);
    
        UITabBarController *tabBarController = [[UITabBarController alloc] init];
        
        NemoContainerViewController *containerVc = [[NemoContainerViewController alloc] init];
        NemoObjectViewController *objectVc = [[NemoObjectViewController alloc] init];
        UIViewController *settingVc = [[UIViewController alloc] init];
        [[settingVc view] setBackgroundColor:[UIColor brownColor]];
        [[settingVc tabBarItem] setTitle:@"Setting"];
        
        NSArray *viewControllers = [NSArray arrayWithObjects:containerVc, objectVc, settingVc, nil];
        
        [tabBarController setViewControllers:viewControllers];
        [self presentViewController:tabBarController animated:YES completion:^(){
        }];
    }
    else
    {
        NSError *error = [[NSError alloc] initWithDomain:@"isUserInfoValid" code:1 userInfo:nil];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid User or Password" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
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
    NSLog(@"textfield:%@", textField);
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
