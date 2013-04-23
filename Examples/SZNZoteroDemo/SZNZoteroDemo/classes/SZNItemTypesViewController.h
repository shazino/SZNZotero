//
//  SZNItemTypesViewController.h
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 23/04/13.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SZNZoteroAPIClient;

@interface SZNItemTypesViewController : UITableViewController

@property (strong, nonatomic) SZNZoteroAPIClient *client;

- (IBAction)cancel:(id)sender;

@end
