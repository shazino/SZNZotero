//
//  SZNNoteViewController.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 22/04/13.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import "SZNNoteViewController.h"
#import <SZNZotero.h>

@interface SZNNoteViewController ()

@end

@implementation SZNNoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.webView loadHTMLString:[NSString stringWithFormat:@"<body contentEditable=\"true\" style=\"font-family:Helvetica;\">%@</body>", self.noteItem.content[@"note"]] baseURL:nil];
}

#pragma mark - Actions

- (NSString *)HTMLString
{
    return [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
}

- (IBAction)save:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSString *HTMLString = [self HTMLString];
    [self.noteItem updatePartialItemWithClient:self.client content:@{@"note" : HTMLString } success:^(SZNItem *item) {
        NSMutableDictionary *content = [NSMutableDictionary dictionaryWithDictionary:self.noteItem.content];
        content[@"note"] = HTMLString;
        self.noteItem.content = content;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } failure:^(NSError *error) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
    }];
}

@end
