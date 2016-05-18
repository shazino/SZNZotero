//
//  SZNItemFieldsViewController.h
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 23/04/13.
//  Copyright (c) 2013-2016 shazino. All rights reserved.
//

@import UIKit;

@class SZNLibrary, SZNItemType;


@interface SZNItemFieldsViewController : UITableViewController

@property (nonatomic, strong, nullable) SZNLibrary *library;
@property (nonatomic, strong, nullable) SZNItemType *itemType;

- (IBAction)done:(nullable id)sender;

@end
