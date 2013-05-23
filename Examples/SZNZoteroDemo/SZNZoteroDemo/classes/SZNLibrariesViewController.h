//
//  SZNLibrariesViewController.h
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 5/21/13.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SZNZoteroAPIClient, SZNUser;


@interface SZNLibrariesViewController : UITableViewController

@property (strong, nonatomic) SZNUser *user;

@end
