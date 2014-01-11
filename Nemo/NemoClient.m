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
@synthesize userName, passWord, containerList, delegate;


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


- (void)setHttpHeader:(NSDictionary *)headerDict withRequestSerializer:(AFHTTPRequestSerializer *)serial
{
    if (!serial) {
        AFHTTPRequestSerializer *newSerial = [[AFHTTPRequestSerializer alloc] init];
        [self setRequestSerializer:newSerial];
    }
    else
    {
        [self setRequestSerializer:serial];
    }
    if (self.requestSerializer) {
        for (NSString *key in headerDict) {
            NMLog(@"Debug: Key----value: %@-----%@", key, headerDict[key]);
            [self.requestSerializer setValue:[headerDict objectForKey:key] forHTTPHeaderField:key];
        }
    }
}


#pragma mark - authentication


- (void)authentication:(NSString *)authType success:(void (^)(UIViewController *vc))successHandler failure:(void (^)(UIViewController *vc, NSError *err))failHandler
{
    
    if ([authType isEqualToString:@"tempAuth"])
    {
        [self getTempAuth:successHandler failure:failHandler];
    }
}


- (void)getTempAuth:(void (^)(UIViewController *vc))success failure:(void (^)(UIViewController *vc, NSError *err))fail
{
    
    // 1. Set header
    [self setHttpHeader:@{@"X-Storage-User":self.userName, @"X-Storage-Pass":self.passWord} withRequestSerializer:nil] ;
    
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
        
        
        void (^displayTask)(NSURLSessionDataTask *t) = ^(NSURLSessionDataTask *task)
        {
            NMLog(@"Debug Get Token Successful from %@", [self.authUrl absoluteString]);
            NMLog(@"Debug countOfBytesExpectedToReceive:  %lld", [task countOfBytesExpectedToReceive]);
            NMLog(@"Debug countOfBytesReceived: %lld", [task countOfBytesReceived]);
            NMLog(@"Debug countOfBytesExpectedToSend:  %lld", [task countOfBytesExpectedToSend]);
            NMLog(@"Debug countOfBytesSent: %lld", [task countOfBytesSent]);
            NMLog(@"Debug request--->header: %@", [[task currentRequest] allHTTPHeaderFields]);
            NMLog(@"Debug request--->method: %@", [[task currentRequest] HTTPMethod]);
            
            NMLog(@"Debug response--->%@", [task response]);
            NMLog(@"Debug account: %@", [[[self storageUrl] componentsSeparatedByString:@"/"] lastObject]);
            NMLog(@"Debug X-Auth-Token: %@", [self authToken]);
            NMLog(@"Debug X-Storage-Url: %@", [self storageUrl]);
        };
        
        /* Display Debug Info */
        displayTask(task);
        
        if (200 <= self.response.statusCode && self.response.statusCode <= 299) {
            self.authToken = [[self.response allHeaderFields] objectForKey:@"X-Auth-Token"];
            self.storageUrl = [[self.response allHeaderFields] objectForKey:@"X-Storage-Url"];
            [self setAuthenticated:YES];
            
            /* Update UI by invoking handler*/
            if (success) {
                success(self.delegate);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [self setResponse:(NSHTTPURLResponse *)[task response]];
        void (^displayErrorResponse)(NSURLSessionDataTask *t) = ^(NSURLSessionDataTask *task)
        {
            
            /* NMLog display Debug info */
            NMLog(@"Debug Get Token Failed from %@", [self.authUrl absoluteString]);
            NMLog(@"Debug response--->%@", [task response]);
            NMLog(@"Debug error:");
            NMLog(@"Debug Error Domain: %@", [error domain]);
            NMLog(@"Debug Error Code: %ld", (long)[error code]);
            NMLog(@"Debug User Info: %@", [error userInfo]);
            
            /* Update UI by invoking handler*/
            if (fail) {
                fail(self.delegate, error);
            }
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
        [self setHttpHeader:@{@"X-Auth-Token": self.authToken} withRequestSerializer:nil];
    }
    
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
    [self setResponseSerializer:jsonSerializer];
    task = [self GET:self.storageUrl parameters:@{@"format": @"json"} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        /* Init container list  here */
        self.containerList = [[NSMutableArray alloc] init];
        
        for (NSDictionary *con in (NSArray*)responseObject) {
            /** Initialize NemoContainer instance with container name 
             *  and then add to container list of the account 
             */
            NemoContainer *container = [[NemoContainer alloc] initWithContainerName:con[@"name"] withMetaData:nil];
            [self.containerList addObject:container];
        }
        NMLog(@"Debug response: %@", [task response]);
        NMLog(@"Debug resopnseObject: %@", responseObject);
        if (successHandler) {
            successHandler(self.containerList, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NMLog(@"Debug error: %@", error);
        if (failureHandler) {
            failureHandler(task, nil);
        }
    }];
    
}

- (void)nemoHeadContainer:(NSString *)containerName success:(void (^)(NSString *containerName, NSError *error))success failure:(void (^)(NSURLSessionTask *task, NSError *error))failure
{
    
    NMLog(@"Debug HEAD Container: %@", containerName);
    
    NSURLSessionDataTask *task = [[NSURLSessionDataTask alloc] init];
    
    AFHTTPRequestSerializer *reqSerializer = [[AFHTTPRequestSerializer alloc] init];
    [self setRequestSerializer:reqSerializer];
    
    AFHTTPResponseSerializer *resSerializer = [[AFHTTPResponseSerializer alloc] init];
    [resSerializer setAcceptableStatusCodes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(200, 99)]];
    [self setResponseSerializer:resSerializer];
    
    if (self.authenticated) {
        [self setHttpHeader:@{@"X-Auth-Token": self.authToken} withRequestSerializer:nil];
    }
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
    [self setResponseSerializer:jsonSerializer];
    
    NSString *headURLString = [NSString stringWithFormat:@"%@/%@", self.storageUrl, containerName];
    
    
    NMLog(@"Debug head URL: %@", headURLString);
    
    task = [self HEAD:headURLString parameters:@{@"format":@"json"} success:^(NSURLSessionDataTask *task) {
        
        NSDictionary *header = [(NSHTTPURLResponse *)[task response] allHeaderFields];
        NMLog(@"Debug HEAD %@", containerName);
        NMLog(@"Debug header: %@", header);
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

- (void)nemoPutContainer:(NemoContainer *)newContainer success:(void (^)(NemoContainer *, NSError *))successHandler failure:(void (^)(NSURLSessionTask *, NSError *))failureHandler
{
    NSURLSessionDataTask *task = [[NSURLSessionDataTask alloc] init];
    
    AFHTTPRequestSerializer *reqSerializer = [[AFHTTPRequestSerializer alloc] init];
    [self setRequestSerializer:reqSerializer];
    
    AFHTTPResponseSerializer *resSerializer = [[AFHTTPResponseSerializer alloc] init];
    [resSerializer setAcceptableStatusCodes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(200, 99)]];
    [self setResponseSerializer:resSerializer];
    
    if (self.authenticated) {
        [self setHttpHeader:@{@"X-Auth-Token": self.authToken} withRequestSerializer:nil];
        if (newContainer.metaData) {
            NMLog(@"Debug --- meta data: %@", newContainer.metaData);
            [self setHttpHeader:newContainer.metaData withRequestSerializer:self.requestSerializer];
            NMLog(@"Header: %@", [[self requestSerializer] HTTPRequestHeaders]);
        }
    }
    
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
    [self setResponseSerializer:jsonSerializer];
    
    /* Swift PUT Container API is: 
     * PUT http://host:port/v1/account/container
     * So need to generate the URL by adding new container
     * name to the tail of storage URL
     */
    NSString *putURLString = [NSString stringWithFormat:@"%@/%@", self.storageUrl, newContainer.containerName];

    task = [self PUT:putURLString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NMLog(@"Debug: PUT Container %@", newContainer.containerName);
        NMLog(@"Debug: PUT Task Description: %@",[task description]);
        NMLog(@"Debug: Response--->%@", [task response]);
        NMLog(@"Debug: Response Object: %@", responseObject);
        if (successHandler) {
            successHandler(newContainer, nil);
        }
        ;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        ;
    }];
    
    
    
    
}

- (void)nemoDeleteContainer:(NSString *)containerName success:(void (^)(NSString *, NSError *))success failure:(void (^)(NSURLSessionTask *, NSError *))failure
{
    NMLog(@"Debug Delete container: %@", containerName);
    
    NSURLSessionDataTask *task = [[NSURLSessionDataTask alloc] init];
    
    AFHTTPRequestSerializer *reqSerializer = [[AFHTTPRequestSerializer alloc] init];
    [self setRequestSerializer:reqSerializer];
    
    AFHTTPResponseSerializer *resSerializer = [[AFHTTPResponseSerializer alloc] init];
    [resSerializer setAcceptableStatusCodes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(200, 99)]];
    [self setResponseSerializer:resSerializer];
    if (self.authenticated) {
        [self setHttpHeader:@{@"X-Auth-Token": self.authToken} withRequestSerializer:nil];
    }
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:0];
    [self setResponseSerializer:jsonSerializer];
    
    NSString *deleteURLString = [NSString stringWithFormat:@"%@/%@", self.storageUrl, containerName];
    
    task = [self DELETE:deleteURLString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NMLog(@"Debug: Delete container: %@ Successfully!", containerName);
        NMLog(@"Debug: response: %@", [task response]);
        NMLog(@"Debug: response Obj: %@", responseObject);
        
        if (success) {
            success(containerName, nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NMLog(@"Debug: Delete container: %@ Failed!", containerName);
        NMLog(@"Debug: response: %@", [task response]);
        NMLog(@"Debug: error: %@", error);
        
        /* Container could not be deleted if it has objects 
         * status code 409 returned if delete an nonempty container
         */
        if ([(NSHTTPURLResponse *)[task response] statusCode] == 409) {
            NMLog(@"Debug: Conflict happens while deleting %@", containerName);
            NSString *msg = [NSString stringWithFormat:@"%@ is not empty, Deletion is forbidden!", containerName];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Failed!" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
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
        NMLog(@"Debug Client Info:");
        NMLog(@"Debug User Name: %@", self.userName);
        NMLog(@"Debug Password:  %@", self.passWord);
        NMLog(@"Debug authenticated?: %d", self.authenticated);
        NMLog(@"Debug auth url: %@", [self.authUrl absoluteString]);
        NMLog(@"Debug auth token: %@", self.authToken);
        NMLog(@"Debug storage url: %@", self.storageUrl);
        NMLog(@"Debug containers: %@", self.containerList);
    }
}


#pragma mark - Delegate 



@end
