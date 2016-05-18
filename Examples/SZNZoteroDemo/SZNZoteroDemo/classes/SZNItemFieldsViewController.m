//
//  SZNItemFieldsViewController.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 23/04/13.
//  Copyright (c) 2013-2016 shazino. All rights reserved.
//

#import "SZNItemFieldsViewController.h"

#import <SZNZotero.h>

@interface SZNItemFieldsViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong, nullable) NSArray <SZNItemField *> *itemFields;
@property (nonatomic, strong, nullable) NSMutableArray <NSString *> *itemValues;

@end


@implementation SZNItemFieldsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem.enabled = NO;

    SZNItemType *itemType = self.itemType;
    SZNZoteroAPIClient *client = self.library.client;

    [SZNItem fetchValidFieldsWithClient:client forItemType:itemType success:^(NSArray <SZNItemField *> *fields) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.itemFields = fields;
        self.itemValues = [NSMutableArray arrayWithCapacity:self.itemFields.count];
        for (NSUInteger index = 0; index < self.itemFields.count; index++) {
            [self.itemValues addObject:@""];
        }

        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.itemFields count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SZNFieldCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    UILabel *cellLabel;
    UITextField *cellTextField;
    for (UIView *subview in cell.contentView.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            cellLabel = (UILabel *)subview;
        }

        if ([subview isKindOfClass:[UITextField class]]) {
            cellTextField = (UITextField *)subview;
        }
    }

    cellLabel.text = self.itemFields[indexPath.row].localizedName;
    NSString *value = self.itemValues[indexPath.row];
    cellTextField.text = value;

    return cell;
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(id)textField.superview.superview];
    NSString *newValue = textField.text ?: @"";
    [self.itemValues replaceObjectAtIndex:indexPath.row withObject:newValue];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;

    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    content[@"itemType"] = self.itemType.type;

    [self.itemFields enumerateObjectsUsingBlock:^(SZNItemField * _Nonnull field, NSUInteger index, BOOL * _Nonnull stop) {
        NSString *value = self.itemValues[index];
        if ([value isEqualToString:@""] == NO) {
            content[field.field] = value;
        }
    }];

    SZNLibrary *library = self.library;
    [SZNItem createItemInLibrary:library content:content success:^(id newItem) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Item Created", nil)
                                    message:nil
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];
    } failure:^(NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
        self.navigationItem.rightBarButtonItem.enabled = YES;
     }];
}

@end
