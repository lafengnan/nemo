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
@property (nonatomic, retain) NSDictionary *metaData;


#pragma mark - Initializer

- (id)initWithContainerName:(NSString *)name withMetaData:(NSDictionary *)meta;
- (id)init;

@end
