//
//  NemoObjectDetailViewController.h
//  Nemo
//
//  Created by lafengnan on 14-1-22.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NemoObject;

@interface NemoObjectDetailViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

#pragma  mark - Properties

@property (nonatomic, retain) NemoObject *objInstance;

@end
