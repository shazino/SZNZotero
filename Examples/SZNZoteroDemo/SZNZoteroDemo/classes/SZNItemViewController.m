//
//  SZNItemViewController.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 19/04/13.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import "SZNItemViewController.h"
#import <SZNZotero.h>
#import "SZNNoteViewController.h"

typedef NS_ENUM(NSUInteger, SZNItemViewControllerSections) {
    SZNItemViewControllerGeneralSection = 0,
    SZNItemViewControllerContentSection,
    SZNItemViewControllerTagsSection,
    SZNItemViewControllerNotesSection
};

@interface SZNItemViewController () <SZNNoteViewDelegate>

@property (strong, nonatomic) NSDictionary *displayableItemContent;
@property (strong, nonatomic) NSArray *notes;

@end

@implementation SZNItemViewController

- (void)setItem:(SZNItem *)item
{
    _item = item;
    self.displayableItemContent = [item.content dictionaryWithValuesForKeys:[[item.content keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return [obj isKindOfClass:[NSString class]] && ![obj isEqualToString:@""];
    }] allObjects]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.item fetchChildItemsWithClient:self.client success:^(NSArray *children) {
        self.notes = children;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SZNNoteViewController class]])
    {
        ((SZNNoteViewController *)segue.destinationViewController).noteItem = self.notes[self.tableView.indexPathForSelectedRow.row];
        ((SZNNoteViewController *)segue.destinationViewController).client = self.client;
        ((SZNNoteViewController *)segue.destinationViewController).delegate = self;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case SZNItemViewControllerGeneralSection:
            return 4;
        case SZNItemViewControllerContentSection:
            return [[self.displayableItemContent allKeys] count];
        case SZNItemViewControllerTagsSection:
            return [self.item.tags count];
        case SZNItemViewControllerNotesSection:
            return [self.notes count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SZNDetailCell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (indexPath.section)
    {
        case SZNItemViewControllerGeneralSection:
        {
            switch (indexPath.row)
            {
                case 0:
                    cell.textLabel.text = @"Title";
                    cell.detailTextLabel.text = self.item.title;
                    break;
                case 1:
                    cell.textLabel.text = @"Type";
                    cell.detailTextLabel.text = self.item.type;
                    break;
                case 2:
                    cell.textLabel.text = @"Author";
                    cell.detailTextLabel.text = self.item.author.name;
                    break;
                case 3:
                    cell.textLabel.text = @"Identifier";
                    cell.detailTextLabel.text = self.item.identifier;
                    break;
            }
        }
            break;
        case SZNItemViewControllerContentSection:
        {
            NSString *key = [self.displayableItemContent allKeys][indexPath.row];
            cell.textLabel.text = key;
            cell.detailTextLabel.text = self.displayableItemContent[key];
        }
            break;
        case SZNItemViewControllerTagsSection:
        {
            SZNTag *tag = [self.item.tags sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]][indexPath.row];
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"🔖 %@", tag.name];
        }
            break;
        case SZNItemViewControllerNotesSection:
        {
            SZNItem *child = self.notes[indexPath.row];
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = child.title;
            if ([child.type isEqualToString:@"note"])
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"📝 %@", child.title];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else
                cell.detailTextLabel.text = child.title;
        }
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == SZNItemViewControllerNotesSection)
    {
        SZNItem *child = self.notes[indexPath.row];
        if ([child.type isEqualToString:@"note"])
            [self performSegueWithIdentifier:@"SZNPushNoteSegue" sender:nil];
    }
}

#pragma mark - Note view delegate

- (void)noteViewController:(SZNNoteViewController *)noteViewController didSaveItem:(SZNItem *)item
{
    NSMutableArray *notes = [NSMutableArray arrayWithArray:self.notes];
    [notes replaceObjectAtIndex:[notes indexOfObject:item] withObject:item];
    self.notes = notes;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SZNItemViewControllerNotesSection] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
