//
//  SZNAttachmentViewController.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 13/05/13.
//  Copyright (c) 2013 shazino. All rights reserved.
//

#import "SZNAttachmentViewController.h"

@interface SZNAttachmentViewController ()

@end

@implementation SZNAttachmentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.webView loadRequest:self.fileURLRequest];
}

@end
