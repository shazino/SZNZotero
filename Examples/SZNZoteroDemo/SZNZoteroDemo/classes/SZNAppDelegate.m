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

#import "SZNItemsViewController.h"

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
    SZNItemsViewController *itemsViewController  = (SZNItemsViewController *)((UINavigationController *)self.window.rootViewController).topViewController;
    itemsViewController.client = client;
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url scheme] isEqualToString:SZNURLScheme])
    {
        NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:[NSDictionary dictionaryWithObject:url forKey:kAFApplicationLaunchOptionsURLKey]];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    return YES;
}

@end
