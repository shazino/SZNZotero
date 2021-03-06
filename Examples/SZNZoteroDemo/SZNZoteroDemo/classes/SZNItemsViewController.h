//
//  SZNItemsViewController.h
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 18/03/13.
//  Copyright (c) 2013-2016 shazino. All rights reserved.
//

@import UIKit;

@class SZNZoteroAPIClient, SZNCollection, SZNLibrary;

@interface SZNItemsViewController : UITableViewController

@property (strong, nonatomic) SZNLibrary *library;
@property (strong, nonatomic) SZNCollection *parentCollection;

- (IBAction)refresh:(id)sender;
- (IBAction)addItem:(id)sender;

@end
