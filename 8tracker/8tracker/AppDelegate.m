//
//  AppDelegate.m
//  8tracker
//
//  Created by Nick Brice on 11/29/12.
//  Copyright (c) 2012 Nick Brice. All rights reserved.
//

#import "AppDelegate.h"
#import "ApplicationRoot.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.applicationRoot = [[ApplicationRoot alloc] init];
}

@end
