//
//  RequestManager.m
//  8tracker
//
//  Created by Nick Brice on 11/30/12.
//  Copyright (c) 2012 Nick Brice. All rights reserved.
//

#import "RequestManager.h"

#import "User.h"

#import "GlobalDefines.h"

@implementation RequestManager

+ (RequestManager *) sharedInstance
{
    static RequestManager * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RequestManager alloc] init];
    });
    
    return sharedInstance;
}

- (id) init
{
    if( self = [super init] )
    {
        _currentUser = nil;
    }
    
    return self;
}

- (void) loginWithUsername:(NSString *) username
                  password:(NSString *) password
              successBlock:(void (^)(User *))success
              failureBlock:(void (^)(NSError *error))failure
{
    [RESTRequest makeRequestWithURL:BASE_URL_SSL
                               path:@"/sessions"
                        requestType:@"POST"
                         parameters:@{ @"login" : username, @"password" : password }
                       successBlock:^(NSMutableDictionary *loginData){
                           NSDictionary *userData = [loginData objectForKey:@"user"];
                           User *loggedInUser = [[User alloc] init];
                           loggedInUser.username = [userData objectForKey:@"login"];
                           loggedInUser.userID = [[userData objectForKey:@"id"] unsignedIntegerValue];
                           loggedInUser.userToken = [userData objectForKey:@"user_token"];
                           
                           success(loggedInUser);
                       }failureBlock:^(NSError *error){
                           
                       }];
}

@end
