//
//  NemoContainer.h
//  Nemo
//
//  Created by lafengnan on 14-1-7.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NemoContainer : NSObject

#pragma mark - Properties

@property (nonatomic, retain) NSString *containerName;
@property (nonatomic, retain) NSDate *createTimeStamp;
@property (nonatomic, retain) NSArray *metaData;


#pragma mark - Initializer

- (id)initWithContainerName:(NSString *)name createAt:(NSDate *)timeStamp metaData:(NSArray *)meta;
- (id)init;

@end
