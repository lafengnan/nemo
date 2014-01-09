//
//  NemoObjectViewController.m
//  Nemo
//
//  Created by lafengnan on 13-12-19.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoObjectViewController.h"

@implementation NemoObjectViewController

@synthesize myWebView;

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Object"];
        [tbi setImage:[UIImage imageNamed:@"object_32"]];
    }
    return self;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *scriptogrURL = [NSURL URLWithString:@"http://www.flickr.com/photos/lafengnan"];
    NSURLRequest *req = [NSURLRequest requestWithURL:scriptogrURL];
    
    [self.myWebView loadRequest:req];
    
}

- (void)loadView
{
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    UIWebView *wv = [[UIWebView alloc] initWithFrame:screenFrame];
    [wv setScalesPageToFit:YES];
    
    [self setView:wv];
}

- (UIWebView *)myWebView
{
    return (UIWebView *)[self view];
}


@end
