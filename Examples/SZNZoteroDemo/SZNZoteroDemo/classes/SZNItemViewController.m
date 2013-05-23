//
//  SZNItemViewController.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 19/04/13.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import "SZNItemViewController.h"
#import <SZNZotero.h>

#import "SZNAttachmentViewController.h"
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

- (IBAction)presentAttachment:(id)sender;

@end

@implementation SZNItemViewController

- (void)setItem:(SZNItem *)item
{
    _item = item;
    self.displayableItemContent = [item.content dictionaryWithValuesForKeys:[[item.content keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return [obj isKindOfClass:[NSString class]] && ![obj isEqualToString:@""];
    }] allObjects]];
    
    if ([item.type isEqualToString:@"attachment"])
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"View Attachment"
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(presentAttachment:)];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.item fetchChildItemsSuccess:^(NSArray *children) {
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
        SZNNoteViewController *noteViewController = (SZNNoteViewController *)segue.destinationViewController;
        noteViewController.noteItem = self.notes[self.tableView.indexPathForSelectedRow.row];
        noteViewController.delegate = self;
    }
    else if ([segue.destinationViewController isKindOfClass:[SZNAttachmentViewController class]])
    {
        ((SZNAttachmentViewController *)segue.destinationViewController).fileURLRequest = [self.item fileURLRequest];
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
            return 3;
        case SZNItemViewControllerContentSection:
            return [[self.displayableItemContent allKeys] count];
        case SZNItemViewControllerTagsSection:
            return [[SZNItemDescriptor tagsForItem:self.item] count];
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
                    cell.detailTextLabel.text = self.item.content[@"title"];
                    break;
                case 1:
                    cell.textLabel.text = @"Type";
                    cell.detailTextLabel.text = self.item.type;
                    break;
                case 2:
                    cell.textLabel.text = @"Key";
                    cell.detailTextLabel.text = self.item.key;
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
            NSSet *tags = [SZNItemDescriptor tagsForItem:self.item];
            NSArray *sortedTags = [tags sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
            SZNTag *tag = sortedTags[indexPath.row];
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"🔖 %@", tag.name];
        }
            break;
        case SZNItemViewControllerNotesSection:
        {
            SZNItem *child = self.notes[indexPath.row];
            cell.textLabel.text = nil;
            if ([child.type isEqualToString:@"note"])
            {
                cell.detailTextLabel.text = @"📝 Note";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else
                cell.detailTextLabel.text = child.content[@"title"];
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
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:SZNItemViewControllerNotesSection]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Actions 

- (IBAction)presentAttachment:(id)sender
{
    [self performSegueWithIdentifier:@"SZNPushAttachmentSegue" sender:sender];
}

@end
