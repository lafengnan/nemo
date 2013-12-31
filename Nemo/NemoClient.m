//
//  NemoClient.m
//  Nemo
//
//  Created by lafengnan on 13-12-22.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoClient.h"

#define NEMO_DEBUG

//static NSString const *proxyUrl = @"http://192.168.1.106:8080";
static NSString const *proxyUrl = @"http://9.123.245.246:8080";

@implementation NemoClient
@synthesize userName, passWord;


#pragma mark - Class Method

static id client = nil;



+ (id)client
{
    return client;
}

#pragma mark - Initializer

+ (void)initialize
{
    if (self == [NemoClient class]) {
        client = [[self alloc] init];
    }
}

- (id)init
{
    return [self initWithAuthURL:[NSURL URLWithString:(NSString *)proxyUrl] User:@"test:tester" withPassword:@"testing"];
}

- (id)initWithAuthURL:(NSURL *)url User:(NSString *)user withPassword:(NSString *)passKey
{
    if (self = [super initWithBaseURL:[NSURL URLWithString:(NSString *)[url absoluteString]]]) {
        [self setAuthUrl:[NSURL URLWithString:@"auth/v1.0" relativeToURL:self.baseURL]];
        [self setUserName:user];
        [self setPassWord:passKey];
    }
    
    return self;
}


- (void)setHttpHeader:(NSDictionary *)headerDict
{
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    if (serializer) {
        for (NSString *key in headerDict) {
            [serializer setValue:[headerDict objectForKey:key] forHTTPHeaderField:key];
        }
        [self setRequestSerializer:serializer];
    }
}


#pragma mark - authentication


- (BOOL)authentication:(NSString *)authType
{
    BOOL rc = YES;
    
    if ([authType isEqualToString:@"tempAuth"])
    {
        rc = [self getTempAuth];
        
    }
    
    return  rc;
}


- (BOOL)getTempAuth
{
    
    __block BOOL rc = YES;
    

    // 1. Set header
    [self setHttpHeader:@{@"X-Storage-User":self.userName, @"X-Storage-Pass":self.passWord}] ;
    
    // Set authentication url to: http://192.168.1.106:8080/auth/v1.0
    self.authUrl = [NSURL URLWithString:@"auth/v1.0" relativeToURL:self.baseURL];
    
    // 2. Set response serializer
    AFHTTPResponseSerializer *resSerializer = [[AFHTTPResponseSerializer alloc] init];
    [resSerializer setAcceptableStatusCodes:[[NSIndexSet alloc] initWithIndex:200]];
    [self setResponseSerializer:resSerializer];
    
    // 3. Set NSURLSessionDataTask instance
    NSURLSessionDataTask *task = [[NSURLSessionDataTask alloc] init];
    
    // 4. Send GET request with header to authUrl
    task = [self GET:[self.authUrl absoluteString] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        [self setResponse:(NSHTTPURLResponse *)[task response]];
        
        if (200 <= self.response.statusCode && self.response.statusCode <= 299) {
            self.authToken = [[self.response allHeaderFields] objectForKey:@"X-Auth-Token"];
            self.storageUrl = [[self.response allHeaderFields] objectForKey:@"X-Storage-Url"];
            [self setAuthenticated:rc];
        }

#ifdef NEMO_DEBUG
        void (^displayTask)(NSURLSessionDataTask *t) = ^(NSURLSessionDataTask *task)
        {
            NSLog(@"Get Token Successful from %@", [self.authUrl absoluteString]);
            NSLog(@"countOfBytesExpectedToReceive:  %lld", [task countOfBytesExpectedToReceive]);
            NSLog(@"countOfBytesReceived: %lld", [task countOfBytesReceived]);
            NSLog(@"countOfBytesExpectedToSend:  %lld", [task countOfBytesExpectedToSend]);
            NSLog(@"countOfBytesSent: %lld", [task countOfBytesSent]);
            NSLog(@"request--->header: %@", [[task currentRequest] allHTTPHeaderFields]);
            NSLog(@"request--->method: %@", [[task currentRequest] HTTPMethod]);
            
            NSLog(@"response--->%@", [task response]);
            NSLog(@"account: %@", [[[self storageUrl] componentsSeparatedByString:@"/"] lastObject]);
            NSLog(@"X-Auth-Token: %@", [self authToken]);
            NSLog(@"X-Storage-Url: %@", [self storageUrl]);
        };

        displayTask(task);
       
#endif
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        
        [self setResponse:(NSHTTPURLResponse *)[task response]];
        void (^displayErrorResponse)(NSURLSessionDataTask *t) = ^(NSURLSessionDataTask *task)
        {
            NSLog(@"Get Token Failed from %@", [self.authUrl absoluteString]);
            NSLog(@"response--->%@", [task response]);
            NSLog(@"error: %@", error);
        };
        
        displayErrorResponse(task);
    }];
    
    return  rc;
}


#pragma mark - HTTP Operations

- (void)nemoGetAccount:(void (^)(NSArray *, NSError *))successHandler failure:(void (^)(NSURLSessionDataTask *, NSError *))failureHandler
{
    NSURLSessionDataTask *task = [[NSURLSessionDataTask alloc] init];
    
    if (self.authenticated) {
        [self setHttpHeader:@{@"X-Auth-Token": self.authToken}];
    }
    
    task = [self GET:self.storageUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *containers = [[NSArray alloc] init];
        NSLog(@"response: %@", [task response]);
        if (successHandler) {
            successHandler(containers,nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@", error);
        if (failureHandler) {
            failureHandler(task, nil);
        }
    }];
    
}

#pragma mark -
- (void)displayClientInfo
{
    if (self == [NemoClient client]) {
        NSLog(@"Client Info:");
        NSLog(@"User Name: %@", self.userName);
        NSLog(@"Password:  %@", self.passWord);
        NSLog(@"authenticated?: %d", self.authenticated);
        NSLog(@"auth url: %@", [self.authUrl absoluteString]);
        NSLog(@"auth token: %@", self.authToken);
        NSLog(@"storage url: %@", self.storageUrl);
    }
}


@end
