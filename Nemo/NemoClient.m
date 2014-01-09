//
//  NemoClient.m
//  Nemo
//
//  Created by lafengnan on 13-12-22.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoClient.h"
#import "NemoContainer.h"


#define NEMO_DEBUG

//static NSString const *proxyUrl = @"http://192.168.1.106:8080";
static NSString const *proxyUrl = @"http://172.16.218.129:8080";
//static NSString const *proxyUrl = @"http://9.123.245.246:8080";

@implementation NemoClient
@synthesize userName, passWord, containerList;


#pragma mark - Class Method

static id client = nil;



+ (id)getClient
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
    return [self initWithAuthURL:[NSURL URLWithString:(NSString *)proxyUrl] User:@"invalid" withPassword:@"invalid"];
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


- (void)authentication:(NSString *)authType
{
    
    if ([authType isEqualToString:@"tempAuth"])
    {
        [self getTempAuth];
    }
}


- (void)getTempAuth
{
    
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
            [self setAuthenticated:YES];
        }
        
            void (^displayTask)(NSURLSessionDataTask *t) = ^(NSURLSessionDataTask *task)
            {
                NMLog(@"Get Token Successful from %@", [self.authUrl absoluteString]);
                NMLog(@"countOfBytesExpectedToReceive:  %lld", [task countOfBytesExpectedToReceive]);
                NMLog(@"countOfBytesReceived: %lld", [task countOfBytesReceived]);
                NMLog(@"countOfBytesExpectedToSend:  %lld", [task countOfBytesExpectedToSend]);
                NMLog(@"countOfBytesSent: %lld", [task countOfBytesSent]);
                NMLog(@"request--->header: %@", [[task currentRequest] allHTTPHeaderFields]);
                NMLog(@"request--->method: %@", [[task currentRequest] HTTPMethod]);
                
                NMLog(@"response--->%@", [task response]);
                NMLog(@"account: %@", [[[self storageUrl] componentsSeparatedByString:@"/"] lastObject]);
                NMLog(@"X-Auth-Token: %@", [self authToken]);
                NMLog(@"X-Storage-Url: %@", [self storageUrl]);
            };
            
            displayTask(task);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [self setResponse:(NSHTTPURLResponse *)[task response]];
        void (^displayErrorResponse)(NSURLSessionDataTask *t) = ^(NSURLSessionDataTask *task)
        {
            NMLog(@"Get Token Failed from %@", [self.authUrl absoluteString]);
            NMLog(@"response--->%@", [task response]);
            NMLog(@"error: %@", error);
        };
        
        displayErrorResponse(task);
        
        
        
    }];
}

#pragma mark - HTTP Operations

- (void)nemoGetAccount:(void (^)(NSArray *containers, NSError *error))successHandler failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failureHandler
{
    NSURLSessionDataTask *task = [[NSURLSessionDataTask alloc] init];
    
    AFHTTPRequestSerializer *reqSerializer = [[AFHTTPRequestSerializer alloc] init];
    [self setRequestSerializer:reqSerializer];
    
    AFHTTPResponseSerializer *resSerializer = [[AFHTTPResponseSerializer alloc] init];
    [resSerializer setAcceptableStatusCodes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(200, 99)]];
    [self setResponseSerializer:resSerializer];
    if (self.authenticated) {
        [self setHttpHeader:@{@"X-Auth-Token": self.authToken}];
    }
    
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
    [self setResponseSerializer:jsonSerializer];
    task = [self GET:self.storageUrl parameters:@{@"format": @"json"} success:^(NSURLSessionDataTask *task, id responseObject) {
        
//        NSDictionary *headers = [(NSHTTPURLResponse* )[task response] allHeaderFields];
        
        /* Init container list  here */
        self.containerList = [[NSMutableArray alloc] init];
        
        for (NSDictionary *con in (NSArray*)responseObject) {
            /** Initialize NemoContainer instance with container name 
             *  and then add to container list of the account 
             */
            NemoContainer *container = [[NemoContainer alloc] initWithContainerName:con[@"name"] withMetaData:nil];
            [self.containerList addObject:container];
        }
//        NMLog(@"response: %@", [task response]);
//        NMLog(@"resopnseObject: %@", responseObject);
        if (successHandler) {
            successHandler(self.containerList, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NMLog(@"error: %@", error);
        if (failureHandler) {
            failureHandler(task, nil);
        }
    }];
    
}

- (void)nemoHeadContainer:(NSString *)containerName success:(void (^)(NSString *containerName, NSError *error))success failure:(void (^)(NSURLSessionTask *task, NSError *error))failure
{
    
    NMLog(@"Start HEADing %@", containerName);
    
    NSURLSessionDataTask *task = [[NSURLSessionDataTask alloc] init];
    
    AFHTTPRequestSerializer *reqSerializer = [[AFHTTPRequestSerializer alloc] init];
    [self setRequestSerializer:reqSerializer];
    
    AFHTTPResponseSerializer *resSerializer = [[AFHTTPResponseSerializer alloc] init];
    [resSerializer setAcceptableStatusCodes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(200, 99)]];
    [self setResponseSerializer:resSerializer];
    if (self.authenticated) {
        [self setHttpHeader:@{@"X-Auth-Token": self.authToken}];
    }
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
    [self setResponseSerializer:jsonSerializer];
    
    NSString *headURLString = [[self.storageUrl stringByAppendingString:@"/"] stringByAppendingString:containerName];
    
    
    NMLog(@"head URL: %@", headURLString);
    
    task = [self HEAD:headURLString parameters:@{@"format":@"json"} success:^(NSURLSessionDataTask *task) {
        
        NSDictionary *header = [(NSHTTPURLResponse *)[task response] allHeaderFields];
        NMLog(@"HEAD %@", containerName);
        NMLog(@"header: %@", header);
        for (NemoContainer *con in self.containerList) {
            if ([con.containerName isEqualToString:containerName]) {
                [con setMetaData:header];
            }
        }
        if (success) {
            success(containerName, nil);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HEAD Container" object:nil];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
    
    [task resume];
}

#pragma mark -

- (void)displayClientInfo
{
    if (self == [NemoClient getClient]) {
        NMLog(@"Client Info:");
        NMLog(@"User Name: %@", self.userName);
        NMLog(@"Password:  %@", self.passWord);
        NMLog(@"authenticated?: %d", self.authenticated);
        NMLog(@"auth url: %@", [self.authUrl absoluteString]);
        NMLog(@"auth token: %@", self.authToken);
        NMLog(@"storage url: %@", self.storageUrl);
        NMLog(@"containers: %@", self.containerList);
    }
}


#pragma mark - Delegate 



@end
