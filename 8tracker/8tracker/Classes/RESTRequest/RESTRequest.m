//
//  RESTRequest.m
//  8tracker
//
//  Created by Nick Brice on 11/29/12.
//  Copyright (c) 2012 Nick Brice. All rights reserved.
//

#import "RESTRequest.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "JSONKit.h"
#import "NSData+JSONString.h"

NSString * DEV_API_KEY = @"f1e67442912eb872696b65a2cdaf4fbd0ac1e9d7";

@implementation RESTRequest

+ (NSString*)stringByHashingWithSHA1:(NSString *) stringToHash
{
    // FIXME: Get our secret key from somewhere else in the game!
    NSString *authToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"authToken"];
    if( !authToken )
    {
        authToken = @"";
    }
    const char* hashKey = [authToken cStringUsingEncoding:NSASCIIStringEncoding];
    const char* hashData = [stringToHash cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char hmacResult[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, hashKey, strlen(hashKey), hashData, strlen(hashData), hmacResult);
    
    //retrieve the output and convert it to a string
    NSData *output = [NSData dataWithBytes:hmacResult length:sizeof(hmacResult)];
    NSString *hashStringOutput = [output description];
    
    //remove the bad characters from the hash string
    hashStringOutput = [hashStringOutput stringByReplacingOccurrencesOfString:@" " withString:@""];
    hashStringOutput = [hashStringOutput stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hashStringOutput = [hashStringOutput stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    return hashStringOutput;
}

+ (NSString*)stringByUrlEncodingString:(NSString*)input
{
    CFStringRef value = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                (CFStringRef) input,
                                                                NULL,
                                                                (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                kCFStringEncodingUTF8);
    
    NSString* result = [NSString stringWithString:(NSString*)value];
    CFRelease(value);
    
    return result;
}

+ (NSString*)buildQueryString:(NSDictionary*)parameters
{
    NSString* queryString = @"";
    
    NSArray* parameterKeys = [parameters allKeys];
    
    for (NSString* parameterKey in parameterKeys)
    {
        NSString* parameter = [parameters objectForKey:parameterKey];
        
        queryString = [queryString stringByAppendingFormat:@"&%@=%@",
                       parameterKey,
                       [self stringByUrlEncodingString:parameter]];
    }
    
    return [queryString substringFromIndex:1];  // Trim the first (unnecessary '&') character.
}

+ (NSDictionary*)convertBinaryPlistToDictionary:(NSData*)responseData
{
    if ( !responseData || responseData.length == 0 ) return nil;
    
    NSError* error = nil;
    NSString* errordesc = nil;
    NSDictionary* response = nil;
    NSPropertyListFormat format = NSPropertyListBinaryFormat_v1_0;
    
    if ( [NSPropertyListSerialization instancesRespondToSelector:@selector(propertyListWithData:options:format:error:)] )
    {
        response = [NSPropertyListSerialization propertyListWithData:responseData
                                                             options:kCFPropertyListImmutable
                                                              format:&format
                                                               error:&error];
        if ( error.code > 0 )
        {
            NSString* debugInfo = [NSString stringWithFormat:@"code: %li\ndomain: %@\nlocalizedDescription: %@",
                                   [error code],
                                   [error domain],
                                   [error localizedDescription]];
            NSLog(@"%@", debugInfo);
            
            return nil;
        }
    }
    else
    {
        response = [NSPropertyListSerialization propertyListFromData:responseData
                                                    mutabilityOption:kCFPropertyListImmutable
                                                              format:&format
                                                    errorDescription:&errordesc];
        
        if ( errordesc )
        {
            NSLog(@"RESTRequest::convertBinaryPlistToDictionary - errorDescription: %@", errordesc);
            return nil;
        }
    }
    
    return response;
}

+ (BOOL)makeRequestWithURL:(NSString*)urlString
                      path:(NSString*)pathString
               requestType:(NSString*)requestMethod
                parameters:(NSDictionary*)parameterList
              successBlock:(CompletionBlock)success
              failureBlock:(FailureBlock)failure
{
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    NSArray* splitVersion = [version componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray* languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString* currentLanguage = [languages objectAtIndex:0];
    
    if ( [splitVersion count] > 0 )
        version = [splitVersion objectAtIndex:0];
    
    //------------------------
    // Create request object.
    //------------------------
    NSString* url = urlString;
    NSString* urlParameterString = nil;
    __block ASIHTTPRequest* request = nil;
    
    // grab the game key from the first url scheme in our bundle
    // - this game key should already exist as it's what brainserver uses to identify the app
    NSBundle* mainBundle;
    
    mainBundle = [NSBundle mainBundle];
    NSArray* urlTypeList = [mainBundle objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    
    NSString* gameType = @"";
    NSDictionary* urlType = [urlTypeList objectAtIndex:0];
    
    if(urlType)
    {
        NSArray* urlSchemeList = [urlType objectForKey:@"CFBundleURLSchemes"];
        
        NSString* urlScheme = [urlSchemeList objectAtIndex:0];
        
        if(urlScheme)
            gameType = urlScheme;
    }
    
    NSMutableDictionary* _parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        version, @"game_version",
                                        currentLanguage, @"language",
                                        nil];
    
    
    if ( parameterList )
    {
        NSArray *paramKeys = [parameterList allKeys];
        for( NSString *key in paramKeys )
        {
            [_parameters setObject:[parameterList objectForKey:key] forKey:key];
        }
    }
    [_parameters setObject:@"json" forKey:@"format"];
    
    if ( [requestMethod isEqualToString:@"POST"] || [requestMethod isEqualToString:@"PUT"] )
    {
        if ( pathString )
        {
            url = [NSString stringWithFormat:@"%@%@", urlString, pathString];
        }
        
        // We always want data to be in JSON
        url = [url stringByAppendingString:@"?format=json"];
        
        request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
        
        //------------------------------------------
        // Build parameter list for post operation.
        //------------------------------------------
        NSArray* keys = [_parameters allKeys];
        
        for (NSString* key in keys)
            [(ASIFormDataRequest*)request setPostValue:[parameterList objectForKey:key] forKey:key];
        [(ASIFormDataRequest*)request buildPostBody];
    }
    else
    {
        urlParameterString = [self buildQueryString:_parameters];
        
        if ( pathString )
            urlString = [NSString stringWithFormat:@"%@%@", urlString, pathString];
        
        if ( urlParameterString )
            url = [NSString stringWithFormat:@"%@?%@", urlString, urlParameterString];
        
        request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    }
    
    // Add our API Key and user token to the header
    [request addRequestHeader:@"X-API-Key" value:DEV_API_KEY];
    
    NSString *userToken = [parameterList objectForKey:@"user_token"];
    if( userToken )
    {
        [request addRequestHeader:@"X-User-Token" value:userToken];
    }
    
    //--------
    // Blocks
    //--------
    [request setCompletionBlock:^(void)
     {
         NSString *jsonString = [[request responseData] dataAsJSON];
         id serverObj = [jsonString mutableObjectFromJSONString];
         
         if ( request.responseStatusCode != 200 )
         {
             //---------------------------------------------------------
             //TODO: Possibly insert some UIAlertView here to describe
             //      the problem to player.
             //---------------------------------------------------------
             [request failWithError:nil];
             return;
         }
         
         //-----------------------
         // Check data integrity.
         //-----------------------
         
         if ( success )
             success ( serverObj );
     }];
    
    [request setFailedBlock:^(void)
     {
         NSError* error = [request error];
         
         NSLog(@"RESTRequest::setFailedBlock - responseStatusCode = %i", request.responseStatusCode);
         NSLog(@"RESTRequest::setFailedBlock - localizedFailureReason = %@", error.localizedFailureReason);
         NSLog(@"RESTRequest::setFailedBlock - localizedDescription = %@", error.localizedDescription);
         NSLog(@"RESTRequest::setFailedBlock - responseString = %@", request.responseString);
         
         if ( failure )
             failure (error);
     }];
    
    //-------------------
    // Caching policies.
    //-------------------
    [request setRequestMethod:requestMethod];
    [request startAsynchronous];
    
    return YES;
}

@end
