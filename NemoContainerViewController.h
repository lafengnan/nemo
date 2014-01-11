//
//  NemoContainerViewController.h
//  Nemo
//
//  Created by lafengnan on 13-12-19.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGORefreshTableHeaderView.h"

@class NemoContainer;

@interface NemoContainerViewController : UITableViewController <EGORefreshTableHeaderDelegate>
{
    BOOL isflage;
    BOOL _reloading;
    EGORefreshTableHeaderView *_refreshHeaderView;
}
@property (nonatomic, retain) NSMutableArray *containerList;


- (id)initWithContainerList:(NSArray *)containers;
- (void)updateContainerList;
- (void)doneUpdatingContainerList;
- (void)addNewContainer:(NemoContainer *)con success:(void (^)())successHandler failure:(void (^)())failureHandler;

@end
