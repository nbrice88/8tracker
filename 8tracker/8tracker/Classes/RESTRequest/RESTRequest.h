//
//  RESTRequest.h
//  8tracker
//
//  Created by Nick Brice on 11/29/12.
//  Copyright (c) 2012 Nick Brice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASIDownloadCache.h"

#define HASH_KEY  @"X-8T-PLISTHASH"

// Notification(s)
#define PFGREQUEST_NO_CONNECTION @"RESTRequestNoConnectionNotification"

typedef void (^CompletionBlock)(id data);
typedef void (^FailureBlock)(NSError* error);

@interface RESTRequest : NSObject

+ (NSString*) stringByHashingWithSHA1:(NSString *) stringToHash;

+ (NSString*) stringByUrlEncodingString:(NSString*) input;

+ (BOOL)makeRequestWithURL:(NSString*)urlString
                      path:(NSString*)pathString
               requestType:(NSString*)requestType
                parameters:(NSDictionary*)parameterList
              successBlock:(CompletionBlock)success
              failureBlock:(FailureBlock)failure;

@end
