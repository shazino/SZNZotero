//
//  SZNItemFieldsViewController.h
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 23/04/13.
//  Copyright (c) 2013-2014 shazino. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SZNLibrary;

@interface SZNItemFieldsViewController : UITableViewController

@property (strong, nonatomic) SZNLibrary *library;
@property (copy, nonatomic) NSString *itemType;

- (IBAction)done:(id)sender;

@end
