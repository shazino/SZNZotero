//
//  SZNLibrariesViewController.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 5/21/13.
//  Copyright (c) 2013-2016 shazino. All rights reserved.
//

#import "SZNLibrariesViewController.h"
#import <SZNZotero.h>
#import "SZNItemsViewController.h"

NS_ENUM(NSUInteger, SZNLibrariesSections) {
    SZNMyLibrarySection = 0,
    SZNGroupsSection
};

NSString *const SZNSessionUserIdentifierKey = @"SZNSessionUserIdentifierKey";
NSString *const SZNSessionUsernameKey       = @"SZNSessionUsernameKey";
NSString *const SZNSessionTokenKey          = @"SZNSessionTokenKey";

@interface SZNLibrariesViewController ()

@property (strong, nonatomic) NSArray *groups;

- (void)fetchGroupsInLibrary:(SZNLibrary *)library;
- (void)saveSessionWithClient:(SZNZoteroAPIClient *)client token:(NSString *)token;
- (BOOL)restoreSession;
- (void)resetSession;
- (void)signOut:(id)sender;
- (void)refreshData:(id)sender;

@end


@implementation SZNLibrariesViewController

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshData:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SZNItemsViewController class]]) {
        SZNItemsViewController *itemsViewController = (SZNItemsViewController *)segue.destinationViewController;
        if (self.tableView.indexPathForSelectedRow.section == SZNMyLibrarySection)
            itemsViewController.library = self.user;
        else
            itemsViewController.library = self.groups[self.tableView.indexPathForSelectedRow.row];
    }
}

#pragma mark - Session

- (void)saveSessionWithClient:(SZNZoteroAPIClient *)client token:(NSString *)token {
    // !!!Warning: the `NSUserDefaults` is not a proper way to store credentials
    // For a production app, you should consider storing them in the user keychain
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:client.userIdentifier forKey:SZNSessionUserIdentifierKey];
    [defaults setObject:client.username forKey:SZNSessionUsernameKey];
    [defaults setObject:token forKey:SZNSessionTokenKey];
    [defaults synchronize];
}

- (void)resetSession {
    [self saveSessionWithClient:nil token:nil];
}

- (BOOL)restoreSession {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userIdentifier = [defaults stringForKey:SZNSessionUserIdentifierKey];
    NSString *username = [defaults stringForKey:SZNSessionUsernameKey];
    NSString *token = [defaults stringForKey:SZNSessionTokenKey];
    
    if (userIdentifier && username && token) {
        self.user.client.accessToken    = [[AFOAuth1Token alloc] initWithQueryString:[NSString stringWithFormat:@"oauth_token=%@&oauth_token_secret=%@", token, token]];
        self.user.client.userIdentifier = userIdentifier;
        self.user.client.username       = username;
        self.user.identifier = userIdentifier;
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - Actions

- (void)signOut:(id)sender {
    [self resetSession];
    
    self.user.client.accessToken    = nil;
    self.user.client.userIdentifier = nil;
    self.user.client.username       = nil;
    self.user.identifier = nil;
    self.groups = nil;
    
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.tableView reloadData];
    [self refreshData:sender];
}

- (void)refreshData:(id)sender {
    if (self.user.client.isLoggedIn || [self restoreSession]) {
        [self.tableView reloadData];
        [self fetchGroupsInLibrary:self.user];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStyleBordered target:self action:@selector(signOut:)];
    }
    else {
        [self.user.client authenticateWithLibraryAccess:YES
                                            notesAccess:YES
                                            writeAccess:YES
                                       groupAccessLevel:SZNZoteroAccessReadWrite
                               webAuthorizationCallback:nil
                                                success:^(AFOAuth1Token *token) {
            self.user.identifier = self.user.client.userIdentifier;
            [self saveSessionWithClient:self.user.client token:token.secret];
            [self refreshData:nil];
        } failure:^(NSError *error) {
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
        }];
    }
}

#pragma mark - Fetch

- (void)fetchGroupsInLibrary:(SZNLibrary *)library {
    [self.user fetchObjectsForResource:[SZNGroup class] path:nil keys:nil specifier:nil success:^(NSArray *groups) {
        for (SZNGroup *group in groups)
            group.client = self.user.client;
        self.groups = groups;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SZNMyLibrarySection:
            return (self.user.client.isLoggedIn) ? @"User Libraries" : nil;
            break;
        case SZNGroupsSection:
            return ([self.groups count] > 0) ? @"Groups Libraries" : nil;
            break;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SZNMyLibrarySection:
            return (self.user.client.isLoggedIn) ? 1 : 0;
            break;
        case SZNGroupsSection:
            return [self.groups count];
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"SZNPushLibrarySegue" sender:nil];
}

@end
