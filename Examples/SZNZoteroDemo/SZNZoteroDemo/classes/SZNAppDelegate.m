//
//  SZNAppDelegate.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 14/03/13.
//  Copyright (c) 2013-2014 shazino. All rights reserved.
//

#import "SZNAppDelegate.h"

#import <AFNetworking.h>
#import <AFOAuth1Client.h>
#import "SZNZotero.h"

#import "SZNLibrariesViewController.h"

NSString * const SZNURLScheme = @"sznzoterodemo";

@implementation SZNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    NSString *clientKey    = @"50deb7b415ab44276310";
    NSString *clientSecret = @"1c521d94225e31dccf62";
    
    SZNZoteroAPIClient *client = [[SZNZoteroAPIClient alloc] initWithKey:clientKey secret:clientSecret URLScheme:SZNURLScheme];
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    SZNLibrariesViewController *librariesViewController = (SZNLibrariesViewController *)navigationController.topViewController;
    librariesViewController.user = (SZNUser *)[SZNUser libraryWithIdentifier:client.userIdentifier client:client];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    if ([[url scheme] isEqualToString:SZNURLScheme]) {
        NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification
                                                                     object:nil
                                                                   userInfo:@{kAFApplicationLaunchOptionsURLKey: url}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    return YES;
}

@end
