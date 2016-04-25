//
//  SZNItemTypesViewController.h
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 23/04/13.
//  Copyright (c) 2013-2016 shazino. All rights reserved.
//

@import UIKit;

@class SZNLibrary;

@interface SZNItemTypesViewController : UITableViewController

@property (strong, nonatomic) SZNLibrary *library;

- (IBAction)cancel:(id)sender;

@end
