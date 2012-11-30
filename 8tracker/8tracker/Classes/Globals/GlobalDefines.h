//
//  GlobalDefines.h
//  8tracker
//
//  Created by Nick Brice on 11/30/12.
//  Copyright (c) 2012 Nick Brice. All rights reserved.
//

enum SortOption
{
    kSortRecent = 0, // Sort by newest
    kSortPopular,
    kSortHot,
    kSortOptionsTotal,
}SortOption;


NSString * BASE_URL = @"http://8tracks.com";
NSString * BASE_URL_SSL = @"https://8tracks.com";
NSString * TEST_LOGIN = @"8trackstest1";
NSString * TEST_PASSWORD = @"8TracksTest";