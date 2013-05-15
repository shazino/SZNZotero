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
#import "SZNItemTypesViewController.h"

typedef NS_ENUM(NSUInteger, SZNItemsViewControllerSections) {
    SZNItemsViewControllerCollectionsSection = 0,
    SZNItemsViewControllerItemsSection,
    SZNItemsViewControllerTagsSection
};


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
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (self.parentCollection)
    {
        self.title = self.parentCollection.title;
        self.navigationItem.backBarButtonItem.title = self.title;
    }
    else
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
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
    else if ([segue.destinationViewController isKindOfClass:[UINavigationController class]])
    {
        ((UINavigationController *)segue.destinationViewController).navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        
        if ([((UINavigationController *)segue.destinationViewController).topViewController isKindOfClass:[SZNItemTypesViewController class]])
        {
            ((SZNItemTypesViewController *)((UINavigationController *)segue.destinationViewController).topViewController).client = self.client;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SZNItemsViewControllerCollectionsSection)
        return [self.collections count];
    else if (section == SZNItemsViewControllerItemsSection)
        return [self.items count];
    else
        return [self.tags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SZNItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == SZNItemsViewControllerCollectionsSection)
    {
        SZNCollection *collection = self.collections[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"📂 %@", collection.title];
        cell.detailTextLabel.text = collection.identifier;
    }
    else if (indexPath.section == SZNItemsViewControllerItemsSection)
    {
        SZNItem *item = self.items[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"📄 %@", item.content[@"title"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@] %@", item.type, item.key];
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
    if (indexPath.section == SZNItemsViewControllerCollectionsSection)
    {
        SZNItemsViewController *itemsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SZNItemsViewController"];
        itemsViewController.parentCollection = self.collections[indexPath.row];
        itemsViewController.client = self.client;
        [self.navigationController pushViewController:itemsViewController animated:YES];
    }
    else if (indexPath.section == SZNItemsViewControllerItemsSection)
        [self performSegueWithIdentifier:@"SZNPushItemSegue" sender:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == SZNItemsViewControllerCollectionsSection)
        return @"Collections";
    else if (section == SZNItemsViewControllerItemsSection)
        return @"Items";
    else
        return @"Tags";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SZNItemsViewControllerItemsSection)
        return YES;
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (indexPath.section == SZNItemsViewControllerItemsSection)
        {
            SZNItem *item = self.items[indexPath.row];
            [item deleteWithClient:self.client success:^{
                NSMutableArray *items = [NSMutableArray arrayWithArray:self.items];
                [items removeObject:item];
                self.items = items;
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            } failure:^(NSError *error) {
                NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
            }];
        }
    }
}

#pragma mark - Actions

- (IBAction)refresh:(id)sender
{
    [self fetchItemsInUserLibrary];
}

- (IBAction)addItem:(id)sender
{
    [self performSegueWithIdentifier:@"SZNShowAddItemSegue" sender:sender];
}

#pragma mark - Fetch

- (void)fetchItemsInUserLibrary
{
    if (self.parentCollection)
    {
        [self.parentCollection fetchTopItemsWithClient:self.client success:^(NSArray *items) {
            self.items = items;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SZNItemsViewControllerItemsSection] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [self.parentCollection fetchSubcollectionsWithClient:self.client success:^(NSArray *collections) {
                self.collections = collections;
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SZNItemsViewControllerCollectionsSection] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                [self.parentCollection fetchTagsWithClient:self.client success:^(NSArray *tags) {
                    self.tags = tags;
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SZNItemsViewControllerTagsSection] withRowAnimation:UITableViewRowAnimationAutomatic];
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
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SZNItemsViewControllerItemsSection] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [SZNCollection fetchTopCollectionsInLibraryWithClient:self.client success:^(NSArray *collections) {
                self.collections = collections;
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SZNItemsViewControllerCollectionsSection] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                [SZNTag fetchTagsInLibraryWithClient:self.client success:^(NSArray *tags) {
                    self.tags = tags;
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SZNItemsViewControllerTagsSection] withRowAnimation:UITableViewRowAnimationAutomatic];
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
