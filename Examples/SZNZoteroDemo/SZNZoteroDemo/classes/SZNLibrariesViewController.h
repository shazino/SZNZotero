//
//  SZNLibrariesViewController.h
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 5/21/13.
//  Copyright (c) 2013-2016 shazino. All rights reserved.
//

@import UIKit;

@class SZNZoteroAPIClient, SZNUser;


@interface SZNLibrariesViewController : UITableViewController

@property (strong, nonatomic) SZNUser *user;

@end
