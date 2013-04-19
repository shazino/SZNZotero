//
//  SZNItemsViewController.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 18/03/13.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import "SZNItemsViewController.h"
#import "SZNZotero.h"

@interface SZNItemsViewController ()

@property (strong, nonatomic) NSArray *items;

- (void)fetchItemsInUserLibrary;

@end


@implementation SZNItemsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.client.isLoggedIn)
    {
        [self fetchItemsInUserLibrary];
    }
    else
    {
        [self.client authenticateWithLibraryAccess:YES notesAccess:YES writeAccess:YES groupAccessLevel:SZNZoteroAccessReadWrite success:^(AFOAuth1Token *token) {
            [self fetchItemsInUserLibrary];
        } failure:^(NSError *error) {
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SZNItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    SZNItem *item = self.items[indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.identifier;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - Fetch

- (void)fetchItemsInUserLibrary
{
    [SZNItem fetchItemsInLibraryWithClient:self.client userIdentifier:self.client.userIdentifier success:^(NSArray *items) {
        self.items = items;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    }];
}

@end
