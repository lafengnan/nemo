//
//  NemoContainerDetailViewController.h
//  Nemo
//
//  Created by lafengnan on 14-1-6.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NemoContainer;
@interface NemoContainerDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *containerName;

@property (weak, nonatomic) IBOutlet UILabel *objectCount;
@property (weak, nonatomic) IBOutlet UILabel *createTimeStamp;
@property (weak, nonatomic) IBOutlet UIImageView *containerImage;

@property (retain, nonatomic) NemoContainer *container;
@end
