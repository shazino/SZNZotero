//
//  SZNAttachmentViewController.m
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 13/05/13.
//  Copyright (c) 2013-2014 shazino. All rights reserved.
//

#import "SZNAttachmentViewController.h"
#import <AFNetworking.h>

@interface SZNAttachmentViewController () <UIWebViewDelegate>

@end

@implementation SZNAttachmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.delegate = self;
    [self.webView loadRequest:self.fileURLRequest];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.webView.isLoading)
        [self.webView stopLoading];
}

#pragma mark - Web view delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
}

@end
