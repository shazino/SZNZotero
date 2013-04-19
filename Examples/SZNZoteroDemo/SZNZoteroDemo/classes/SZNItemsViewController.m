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

@property (strong, nonatomic) NSArray *collections;
@property (strong, nonatomic) NSArray *items;

- (void)fetchItemsInUserLibrary;

@end


@implementation SZNItemsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [self.collections count];
    else
        return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SZNItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0)
    {
        SZNCollection *collection = self.collections[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"📂 %@", collection.title];
        cell.detailTextLabel.text = collection.identifier;
    }
    else
    {
        SZNItem *item = self.items[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"📄 %@", item.title];
        cell.detailTextLabel.text = item.identifier;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Collections";
    else
        return @"Items";
}

#pragma mark - Actions

- (IBAction)refresh:(id)sender
{
    [self fetchItemsInUserLibrary];
}

#pragma mark - Fetch

- (void)fetchItemsInUserLibrary
{
    [SZNItem fetchTopItemsInLibraryWithClient:self.client success:^(NSArray *items) {
        self.items = items;
        [self.tableView reloadData];
        
        [SZNCollection fetchTopCollectionsInLibraryWithClient:self.client success:^(NSArray *collections) {
            self.collections = collections;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        } failure:^(NSError *error) {
            [self.refreshControl endRefreshing];
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
        }];
    } failure:^(NSError *error) {
        [self.refreshControl endRefreshing];
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    }];
}

@end
