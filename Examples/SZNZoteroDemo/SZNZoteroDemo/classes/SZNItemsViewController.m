//
//  SZNItemsViewController.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 18/03/13.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import "SZNItemsViewController.h"

#import <SZNZotero.h>
#import "SZNItemViewController.h"

@interface SZNItemsViewController ()

@property (strong, nonatomic) NSArray *collections;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSArray *tags;

- (void)fetchItemsInUserLibrary;

@end


@implementation SZNItemsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.parentCollection)
    {
        self.title = self.parentCollection.title;
        self.navigationItem.backBarButtonItem.title = self.title;
    }
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SZNItemViewController class]])
    {
        ((SZNItemViewController *)segue.destinationViewController).client = self.client;
        ((SZNItemViewController *)segue.destinationViewController).item = self.items[self.tableView.indexPathForSelectedRow.row];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [self.collections count];
    else if (section == 1)
        return [self.items count];
    else
        return [self.tags count];
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
    else if (indexPath.section == 1)
    {
        SZNItem *item = self.items[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"📄 %@", item.title];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@] %@", item.type, item.identifier];
    }
    else
    {
        SZNTag *tag = self.tags[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"🔖 %@", tag.name];
        cell.detailTextLabel.text = nil;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        SZNItemsViewController *itemsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SZNItemsViewController"];
        itemsViewController.parentCollection = self.collections[indexPath.row];
        itemsViewController.client = self.client;
        [self.navigationController pushViewController:itemsViewController animated:YES];
    }
    else if (indexPath.section == 1)
        [self performSegueWithIdentifier:@"SZNPushItemSegue" sender:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Collections";
    else if (section == 1)
        return @"Items";
    else
        return @"Tags";
}

#pragma mark - Actions

- (IBAction)refresh:(id)sender
{
    [self fetchItemsInUserLibrary];
}

#pragma mark - Fetch

- (void)fetchItemsInUserLibrary
{
    if (self.parentCollection)
    {
        [self.parentCollection fetchTopItemsWithClient:self.client success:^(NSArray *items) {
            self.items = items;
            [self.tableView reloadData];
            
            [self.parentCollection fetchSubcollectionsWithClient:self.client success:^(NSArray *collections) {
                self.collections = collections;
                [self.tableView reloadData];
                
                [self.parentCollection fetchTagsWithClient:self.client success:^(NSArray *tags) {
                    self.tags = tags;
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
        } failure:^(NSError *error) {
            [self.refreshControl endRefreshing];
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
        }];
    }
    else
    {
        [SZNItem fetchTopItemsInLibraryWithClient:self.client success:^(NSArray *items) {
            self.items = items;
            [self.tableView reloadData];
            
            [SZNCollection fetchTopCollectionsInLibraryWithClient:self.client success:^(NSArray *collections) {
                self.collections = collections;
                [self.tableView reloadData];
                
                [SZNTag fetchTagsInLibraryWithClient:self.client success:^(NSArray *tags) {
                    self.tags = tags;
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
        } failure:^(NSError *error) {
            [self.refreshControl endRefreshing];
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
        }];
    }
}

@end
