//
//  SZNItemViewController.h
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 19/04/13.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SZNZoteroAPIClient, SZNItem, SZNLibrary;

@interface SZNItemViewController : UITableViewController

@property (strong, nonatomic) SZNLibrary *library;
@property (nonatomic, strong) SZNItem *item;

@end
