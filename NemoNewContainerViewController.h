//
//  NemoNewContainerViewController.h
//  Nemo
//
//  Created by lafengnan on 14-1-11.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NemoContainer;

@interface NemoNewContainerViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *containerName;
@property (weak, nonatomic) IBOutlet UISwitch *isRetention;
@property (weak, nonatomic) IBOutlet UITableView *metaDataTableView;

@property (nonatomic, retain) NemoContainer *addContainer;


//
//- (IBAction)addNewContainer:(id)sender;
//- (IBAction)canCellAddNewContainer:(id)sender;



@end
