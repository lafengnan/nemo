//
//  HomePageViewController.h
//  Nemo
//
//  Created by lafengnan on 13-12-18.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NemoClient.h"
@class NemoAccount;


@interface HomePageViewController : UIViewController <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *userName;

@property (weak, nonatomic) IBOutlet UITextField *passKey;

@property (weak, nonatomic) IBOutlet UIImageView *logo;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginIndicator;


#pragma mark - UIAction

- (IBAction)doLogin:(id)sender;

@end
