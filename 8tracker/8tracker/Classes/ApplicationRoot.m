//
//  ApplicationRoot.m
//  8tracker
//
//  Created by Nick Brice on 11/30/12.
//  Copyright (c) 2012 Nick Brice. All rights reserved.
//

#import "ApplicationRoot.h"
#import "RequestManager.h"
#import "GlobalDefines.h"

#import "User.h"

@implementation ApplicationRoot

- (id) init
{
    if( self = [super init] )
    {
        [[RequestManager sharedInstance] loginWithUsername:TEST_LOGIN
                                                  password:TEST_PASSWORD
                                              successBlock:^(User * loggedInUser){
                                                  _currentUser = loggedInUser;
                                                  [RequestManager sharedInstance].currentUser = _currentUser;
                                              }failureBlock:^(NSError * error){
                                                  NSLog(@"Failed to login\n\t user:%@\n\t password:%@", TEST_LOGIN, TEST_PASSWORD);
                                              }];
    }
    
    return self;
}

@end
