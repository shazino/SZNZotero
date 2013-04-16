//
//  SZNItemsViewController.h
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 18/03/13.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SZNZoteroAPIClient;


@interface SZNItemsViewController : UITableViewController

@property (strong, nonatomic) SZNZoteroAPIClient *client;

@end
