//
//  NemoObjectViewController.h
//  Nemo
//
//  Created by lafengnan on 13-12-19.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGORefreshTableHeaderView.h"
#import "NemoObject.h"

@interface NemoObjectViewController : UITableViewController <EGORefreshTableHeaderDelegate>
{
    BOOL isflage;
    BOOL _reloading;
    EGORefreshTableHeaderView *_refreshHeaderView;
}

//@property (nonatomic, readonly) UIWebView *myWebView;

@property (nonatomic, retain) NSMutableArray *objectList;


- (id)initWithObjectList:(NSMutableArray *)objects;
- (void)updateObjectList;
- (void)doneUpdatingObjectList;

- (IBAction)addNewObject:(id)sender;


@end
