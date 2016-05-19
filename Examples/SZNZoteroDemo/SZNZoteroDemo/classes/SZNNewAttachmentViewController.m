//
//  SZNNewAttachmentViewController.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 6/25/13.
//  Copyright (c) 2013-2016 shazino. All rights reserved.
//

#import "SZNNewAttachmentViewController.h"

#import <SZNZotero.h>


@implementation SZNNewAttachmentViewController

#pragma mark - Actions

- (IBAction)uploadAttachment:(id)sender {
    if ([self.titleTextField.text length] == 0 || [self.contentTextField.text length] == 0) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                    message:NSLocalizedString(@"Please enter title and content", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];

        return;
    }

    self.navigationItem.rightBarButtonItem.enabled = NO;

    void(^failure)(NSError *error) = ^void(NSError *error) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    };

    SZNLibrary *library = self.library;
    [SZNItemType fetchNewAttachmentTemplateWithClient:library.client linkMode:SZNAttachmentLinkModeImportedFile success:^(NSDictionary *fields) {
        NSMutableDictionary *itemFields = [fields mutableCopy];
        itemFields[@"title"] = self.titleTextField.text;
        [itemFields removeObjectForKey:@"contentType"];
        [itemFields removeObjectForKey:@"charset"];
        [itemFields removeObjectForKey:@"filename"];
        [itemFields removeObjectForKey:@"md5"];
        [itemFields removeObjectForKey:@"mtime"];

        [SZNItem createItemInLibrary:library content:itemFields success:^(SZNItem *newItem) {
            NSString *title = [self.titleTextField.text stringByAppendingPathExtension:@"txt"];
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:title];
            [self.contentTextField.text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];

            [newItem fetchUploadAuthorizationForFileAtURL:[NSURL fileURLWithPath:filePath] contentType:@"text/plain" success:^(NSDictionary *response, NSString *md5) {
                NSString *prefix = response[@"prefix"];
                NSString *suffix = response[@"suffix"];
                NSString *URL = response[@"url"];
                NSString *contentType = response[@"contentType"];
                NSString *uploadKey = response[@"uploadKey"];

                [newItem
                 uploadFileAtURL:[NSURL fileURLWithPath:filePath]
                 withPrefix:prefix
                 suffix:suffix
                 toURL:URL
                 contentType:contentType
                 uploadKey:uploadKey
                 success:^{
                     self.navigationItem.rightBarButtonItem.enabled = YES;
                     [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"File Uploaded", nil)
                                                 message:nil
                                                delegate:nil
                                       cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                       otherButtonTitles:nil] show];
                 }
                 failure:failure];
            } failure:failure];
        } failure:failure];
    } failure:failure];
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.titleTextField) {
        [self.contentTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }

    return NO;
}

@end
