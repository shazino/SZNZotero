//
//  SZNNewAttachmentViewController.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 6/25/13.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import "SZNNewAttachmentViewController.h"
#import <SZNZotero.h>

@interface SZNNewAttachmentViewController () <UITextFieldDelegate>

@end


@implementation SZNNewAttachmentViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Actions

- (IBAction)uploadAttachment:(id)sender {
    if ([self.titleTextField.text length] > 0 && [self.contentTextField.text length] > 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        [SZNItem fetchAttachmentItemTemplateWithClient:self.library.client linkMode:@"imported_file" success:^(NSDictionary *fields) {
            NSMutableDictionary *itemFields = [fields mutableCopy];
            itemFields[@"title"] = self.titleTextField.text;
            [itemFields removeObjectForKey:@"contentType"];
            [itemFields removeObjectForKey:@"charset"];
            [itemFields removeObjectForKey:@"filename"];
            [itemFields removeObjectForKey:@"md5"];
            [itemFields removeObjectForKey:@"mtime"];
            [SZNItem createItemInLibrary:self.library content:itemFields success:^(SZNItem *newItem) {
                
                NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self.titleTextField.text stringByAppendingPathExtension:@"txt"]];
                [self.contentTextField.text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                [newItem fetchUploadAuthorizationForFileAtURL:[NSURL fileURLWithPath:filePath] contentType:@"text/plain" success:^(NSDictionary *response) {
                    
                    [newItem uploadFileAtURL:[NSURL fileURLWithPath:filePath]
                                  withPrefix:response[@"prefix"]
                                      suffix:response[@"suffix"]
                                       toURL:response[@"url"]
                                 contentType:response[@"contentType"]
                                   uploadKey:response[@"uploadKey"]
                                     success:^{
                                         self.navigationItem.rightBarButtonItem.enabled = YES;
                                         [[[UIAlertView alloc] initWithTitle:@"File Uploaded" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                     } failure:^(NSError *error) {
                                         self.navigationItem.rightBarButtonItem.enabled = YES;
                                         NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
                     }];
                } failure:^(NSError *error) {
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
                }];
            } failure:^(NSError *error) {
                self.navigationItem.rightBarButtonItem.enabled = YES;
                NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
            }];
        } failure:^(NSError *error) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
        }];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter title and content" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.titleTextField)
        [self.contentTextField becomeFirstResponder];
    else
        [textField resignFirstResponder];
    return NO;
}

@end
