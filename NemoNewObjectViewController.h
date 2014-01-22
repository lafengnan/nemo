//
//  NemoNewObjectViewController.h
//  Nemo
//
//  Created by lafengnan on 14-1-22.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NemoObject, NemoContainer;

@interface NemoNewObjectViewController : UIViewController <UITextFieldDelegate>


#pragma mark - Properties
@property (weak, nonatomic) IBOutlet UITextField *objectName;
@property (weak, nonatomic) IBOutlet UITextField *containerName;
@property (weak, nonatomic) IBOutlet UISwitch *isCopy;

@property (nonatomic, retain) NemoObject *nemoNewObject;
@property (nonatomic, retain) NemoContainer *container;

- (IBAction)uploadFile:(id)sender;
- (IBAction)copyFromExistingContainer:(id)sender;

@end
