//
//  SZNItemFieldsViewController.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 23/04/13.
//  Copyright (c) 2013-2014 shazino. All rights reserved.
//

#import "SZNItemFieldsViewController.h"

#import <SZNZotero.h>

@interface SZNItemFieldsViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *itemFields;

@end


@implementation SZNItemFieldsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [SZNItem fetchValidFieldsWithClient:self.library.client forType:self.itemType success:^(NSArray *fields) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.itemFields = [fields mutableCopy];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.itemFields count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SZNFieldCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    UILabel *cellLabel;
    UITextField *cellTextField;
    for (UIView *subview in cell.contentView.subviews) {
        if ([subview isKindOfClass:[UILabel class]])
            cellLabel = (UILabel *)subview;
        if ([subview isKindOfClass:[UITextField class]])
            cellTextField = (UITextField *)subview;
    }
    
    cellLabel.text = self.itemFields[indexPath.row][@"localized"];
    cellTextField.text = self.itemFields[indexPath.row][@"value"];
    
    return cell;
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(id)textField.superview.superview];
    NSMutableDictionary *field = [NSMutableDictionary dictionaryWithDictionary:self.itemFields[indexPath.row]];
    field[@"value"] = textField.text;
    [self.itemFields replaceObjectAtIndex:indexPath.row withObject:field];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    content[@"itemType"] = self.itemType;
    for (NSDictionary *field in self.itemFields) {
        if (field[@"value"])
            content[field[@"field"]] = field[@"value"];
    }
    
    [SZNItem createItemInLibrary:self.library content:content success:^(id newItem) {
        [[[UIAlertView alloc] initWithTitle:@"New Item Created"
                                    message:nil
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } failure:^(NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
        self.navigationItem.rightBarButtonItem.enabled = YES;
     }];
}

@end
