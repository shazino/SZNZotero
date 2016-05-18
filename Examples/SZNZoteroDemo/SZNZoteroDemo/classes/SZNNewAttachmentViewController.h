//
//  SZNNewAttachmentViewController.h
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 6/25/13.
//  Copyright (c) 2013-2016 shazino. All rights reserved.
//

@import UIKit;

@class SZNLibrary;


@interface SZNNewAttachmentViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak, nullable) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak, nullable) IBOutlet UITextField *contentTextField;

@property (nonatomic, strong, nullable) SZNLibrary *library;

- (IBAction)uploadAttachment:(nullable id)sender;

@end
