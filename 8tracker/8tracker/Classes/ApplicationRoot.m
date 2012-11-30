//
//  ApplicationRoot.m
//  8tracker
//
//  Created by Nick Brice on 11/30/12.
//  Copyright (c) 2012 Nick Brice. All rights reserved.
//

#import "ApplicationRoot.h"
#import "RESTRequest.h"
#import "GlobalDefines.h"

#import "User.h"

@implementation ApplicationRoot

- (id) init
{
    if( self = [super init] )
    {
        __block NSString *userToken = @"";
        [RESTRequest makeRequestWithURL:BASE_URL_SSL
                                   path:@"/sessions"
                            requestType:@"POST"
                             parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                         TEST_LOGIN, @"login",
                                         TEST_PASSWORD, @"password",
                                         nil]
                           successBlock:^(NSMutableDictionary *loginData){
                               NSDictionary *userData = [loginData objectForKey:@"user"];
                               User *currentUser = [[User alloc] init];
                               currentUser.username = [userData objectForKey:@"login"];
                               currentUser.userID = [[userData objectForKey:@"id"] unsignedIntegerValue];
                               currentUser.userToken = [userData objectForKey:@"user_token"];
                               
                               userToken = currentUser.userToken;
                           }failureBlock:^(NSError *error){
                               NSInteger x = 2;
                               x = 3;
                           }];
    }
    
    return self;
}

@end
