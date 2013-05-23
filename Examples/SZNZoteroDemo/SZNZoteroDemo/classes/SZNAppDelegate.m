//
//  SZNAppDelegate.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 14/03/13.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import "SZNAppDelegate.h"

#import <AFNetworking.h>
#import <AFOAuth1Client.h>
#import "SZNZotero.h"

#import "SZNLibrariesViewController.h"

NSString * const SZNURLScheme = @"sznzoterodemo";

@interface SZNAppDelegate ()

@end


@implementation SZNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    NSString *clientKey = @"###";
    NSString *clientSecret = @"###";
    
    SZNZoteroAPIClient *client = [[SZNZoteroAPIClient alloc] initWithKey:clientKey secret:clientSecret URLScheme:SZNURLScheme];
    
    SZNLibrariesViewController *librariesViewController = (SZNLibrariesViewController *)((UINavigationController *)self.window.rootViewController).topViewController;
    librariesViewController.user = (SZNUser *)[SZNUser libraryWithIdentifier:client.userIdentifier client:client];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url scheme] isEqualToString:SZNURLScheme])
    {
        NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:@{kAFApplicationLaunchOptionsURLKey: url}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    return YES;
}

@end
