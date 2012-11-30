//
//  RequestManager.h
//  8tracker
//
//  Created by Nick Brice on 11/30/12.
//  Copyright (c) 2012 Nick Brice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTRequest.h"

@class User;

@interface RequestManager : NSObject

@property User * currentUser;

+ (RequestManager *) sharedInstance;

// Attempts to log in with the given credentials
- (void) loginWithUsername:(NSString *) username
                  password:(NSString *) password
              successBlock:(void (^)(User *)) success
              failureBlock:(void (^)(NSError *error)) failure;

@end
