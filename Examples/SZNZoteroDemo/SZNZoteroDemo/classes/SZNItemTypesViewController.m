//
//  SZNItemTypesViewController.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 23/04/13.
//  Copyright (c) 2013-2016 shazino. All rights reserved.
//

#import "SZNItemTypesViewController.h"

#import <SZNZotero.h>
#import "SZNItemFieldsViewController.h"
#import "SZNNewAttachmentViewController.h"

@interface SZNItemTypesViewController ()

@property (nonatomic, strong, nullable) NSArray <SZNItemType *> *itemTypes;

@end


@implementation SZNItemTypesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [SZNItemType fetchTypesWithClient:self.library.client success:^(NSArray <SZNItemType * > *types) {
        self.itemTypes = types;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SZNItemFieldsViewController class]]) {
        SZNItemFieldsViewController *itemFieldsViewController = (SZNItemFieldsViewController *)segue.destinationViewController;
        itemFieldsViewController.library = self.library;
        itemFieldsViewController.itemType = self.itemTypes[self.tableView.indexPathForSelectedRow.row];
    }
    else if ([segue.destinationViewController isKindOfClass:[SZNNewAttachmentViewController class]]) {
        SZNNewAttachmentViewController *newAttachmentViewController = (SZNNewAttachmentViewController *)segue.destinationViewController;
        newAttachmentViewController.library = self.library;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.itemTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SZNTypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.itemTypes[indexPath.row].localizedName;
    return cell;
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
