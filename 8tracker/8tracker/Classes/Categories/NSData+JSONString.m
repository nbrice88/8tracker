//
//  NSData+JSONString.m
//  cardgame
//
//  Created by Nicholas Brice on 10/24/12.
//  Copyright (c) 2012 The Playforge. All rights reserved.
//

#import "NSData+JSONString.h"

@implementation NSData (JSONString)

- (NSString *) dataAsJSON
{
    NSString *responseDataAsJSON = @"";
    char *bytes = (char *)[self bytes];
    char lastByte = bytes[[self length] - 1];
    
    if( lastByte == '\0' )
    {
        responseDataAsJSON = [NSString stringWithUTF8String:[self bytes]];
    }
    else
    {
        responseDataAsJSON = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    }
    
    return responseDataAsJSON;
}

@end
