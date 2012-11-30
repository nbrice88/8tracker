//
//  AppDelegate.m
//  8tracker
//
//  Created by Nick Brice on 11/29/12.
//  Copyright (c) 2012 Nick Brice. All rights reserved.
//

#import "AppDelegate.h"
#import "RESTRequest.h"
#import "JSONKit.h"
#import "User.h"

NSString const *BASE_URL = @"http://8tracks.com";
NSString const *TEST_LOGIN = @"8trackstest1";
NSString const *TEST_PASSWORD = @"8TracksTest";

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    __block NSString *userToken = @"";
    [RESTRequest makeRequestWithURL:@"https://8tracks.com"
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

@end
