//
//  SZNNoteViewController.h
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 22/04/13.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SZNNoteViewDelegate;
@class SZNZoteroAPIClient, SZNItem;

@interface SZNNoteViewController : UIViewController

@property (strong, nonatomic) SZNZoteroAPIClient *client;
@property (strong, nonatomic) SZNItem *noteItem;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)save:(id)sender;

@end

@protocol SZNNoteViewDelegate <NSObject>

- (void)noteViewController:(SZNNoteViewController *)noteViewController didSaveItem:(SZNItem *)item;

@end
