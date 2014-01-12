//
//  NemoObject.h
//  Nemo
//
//  Created by lafengnan on 14-1-12.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NemoObject : NSObject

#pragma mark - Properties

@property (nonatomic, retain) NSString *objectName;
@property (nonatomic, retain) NSString *size;
@property (nonatomic, retain) NSString *etag;
@property (nonatomic, retain) NSString *lastUpdated;
@property (nonatomic, retain) NSString *contentType;
@property (nonatomic, retain) UIImage *objectTypeImage;
@property (nonatomic, retain) NSMutableArray *objectMetaData;


#pragma mark - Initializer

- (id)initWithObjectName:(NSString *)name imageType:(UIImage *)image andMetaData:(NSMutableArray *)meta;

@end
