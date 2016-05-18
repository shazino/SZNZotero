//
//  SZNAttachmentViewController.h
//  SZNZoteroDemo
//
//  Created by Vincent Tourraine on 13/05/13.
//  Copyright (c) 2013-2016 shazino. All rights reserved.
//

@import UIKit;


@interface SZNAttachmentViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak, nullable) IBOutlet UIWebView *webView;
@property (nonatomic, strong, nullable) NSURLRequest *fileURLRequest;

@end
