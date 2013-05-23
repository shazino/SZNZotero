//
//  SZNItemTypesViewController.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 23/04/13.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import "SZNItemTypesViewController.h"

#import <SZNZotero.h>
#import "SZNItemFieldsViewController.h"

@interface SZNItemTypesViewController ()

@property (strong, nonatomic) NSArray *itemTypes;

@end

@implementation SZNItemTypesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SZNItem fetchTypesWithClient:self.library.client success:^(NSArray *types) {
        self.itemTypes = types;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SZNItemFieldsViewController class]]) {
        ((SZNItemFieldsViewController *)segue.destinationViewController).library = self.library;
        ((SZNItemFieldsViewController *)segue.destinationViewController).itemType = self.itemTypes[self.tableView.indexPathForSelectedRow.row][@"itemType"];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.itemTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SZNTypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.itemTypes[indexPath.row][@"localized"];
    return cell;
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
