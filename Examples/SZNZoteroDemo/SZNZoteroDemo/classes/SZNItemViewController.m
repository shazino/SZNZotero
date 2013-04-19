//
//  SZNItemViewController.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 19/04/13.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import "SZNItemViewController.h"
#import <SZNZotero.h>

typedef NS_ENUM(NSUInteger, SZNItemViewControllerSections) {
    SZNItemViewControllerGeneralSection = 0,
    SZNItemViewControllerContentSection,
    SZNItemViewControllerTagsSection,
    SZNItemViewControllerNotesSection
};

@interface SZNItemViewController ()

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
            return 3;
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
        }
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

@end
