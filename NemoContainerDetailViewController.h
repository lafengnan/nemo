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

@property (weak, nonatomic) IBOutlet UILabel *bytesUsed;

@property (weak, nonatomic) IBOutlet UILabel *objectCount;
@property (weak, nonatomic) IBOutlet UILabel *createTimeStamp;
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;

@property (retain, nonatomic) NemoContainer *container;

- (UIImage *)generateQRImageWithContainer:(NSString *)containerName
                                bytesUsed:(NSString *)bytes
                              objectCount:(NSString *)cnt
                                createdAt:(NSString *)timestamp;

@end
