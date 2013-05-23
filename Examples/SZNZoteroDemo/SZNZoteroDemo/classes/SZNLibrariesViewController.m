//
//  SZNLibrariesViewController.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 5/21/13.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import "SZNLibrariesViewController.h"
#import <SZNZotero.h>
#import "SZNItemsViewController.h"

NS_ENUM(NSUInteger, SZNLibrariesSections)
{
    SZNMyLibrarySection = 0,
    SZNGroupsSection
};

@interface SZNLibrariesViewController ()

@property (strong, nonatomic) NSArray *groups;

- (void)fetchGroupsInLibrary:(SZNLibrary *)library;

@end


@implementation SZNLibrariesViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if (self.user.client.isLoggedIn)
    {
        [self fetchGroupsInLibrary:self.user];
    }
    else
    {
        [self.user.client authenticateWithLibraryAccess:YES notesAccess:YES writeAccess:YES groupAccessLevel:SZNZoteroAccessReadWrite success:^(AFOAuth1Token *token) {
            [self fetchGroupsInLibrary:self.user];
        } failure:^(NSError *error) {
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SZNItemsViewController class]])
    {
        SZNItemsViewController *itemsViewController = (SZNItemsViewController *)segue.destinationViewController;
        if (self.tableView.indexPathForSelectedRow.section == SZNMyLibrarySection)
            itemsViewController.library = self.user;
        else
            itemsViewController.library = self.groups[self.tableView.indexPathForSelectedRow.row];
    }
}

#pragma mark - Fetch

- (void)fetchGroupsInLibrary:(SZNLibrary *)library
{
    [self.user fetchObjectsForResource:[SZNGroup class] keys:nil specifier:nil success:^(NSArray *groups) {
        for (SZNGroup *group in groups)
            group.client = self.user.client;
        self.groups = groups;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SZNGroupsSection]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    } failure:^(NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SZNMyLibrarySection:
            return @"User Libraries";
            break;
        case SZNGroupsSection:
            return ([self.groups count] > 0) ? @"Groups Libraries" : nil;
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SZNMyLibrarySection:
            return 1;
            break;
        case SZNGroupsSection:
            return [self.groups count];
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SZNLibraryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    SZNGroup *group;
    
    switch (indexPath.section) {
        case SZNMyLibrarySection:
            cell.textLabel.text = @"📦 My Library";
            break;
        case SZNGroupsSection:
            group = self.groups[indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"👥 %@", group.content[@"name"]];
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"SZNPushLibrarySegue" sender:nil];
}

@end
