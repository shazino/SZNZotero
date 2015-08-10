//
//  AppDelegate.m
//  SZNZoteroDemoOSX
//
//  Created by Vincent Tourraine on 8/10/15.
//  Copyright (c) 2015 shazino. All rights reserved.
//

#import "AppDelegate.h"

#import <SZNZotero.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    SZNZoteroAPIClient *client = [[SZNZoteroAPIClient alloc] initWithBaseURL:nil key:nil secret:nil];
    client = nil;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    // Insert code here to tear down your application
}

@end
