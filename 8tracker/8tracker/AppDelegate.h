//
//  AppDelegate.h
//  8tracker
//
//  Created by Nick Brice on 11/29/12.
//  Copyright (c) 2012 Nick Brice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ApplicationRoot;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property ApplicationRoot * applicationRoot;
@property (assign) IBOutlet NSWindow *window;

@end
