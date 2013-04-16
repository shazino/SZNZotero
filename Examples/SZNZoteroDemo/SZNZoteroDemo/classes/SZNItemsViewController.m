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

@end


@implementation SZNItemsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.client authenticateWithSuccess:^(AFOAuth1Token *token) {
        NSLog(@"%s Token Key: %@", __PRETTY_FUNCTION__, token.key);

        [SZNItem fetchItemsInLibraryWithUserIdentifier:self.client.userIdentifier client:self.client success:^(NSArray *items) {
            NSLog(@"%@", items);
            self.items = items;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    }];
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

@end
