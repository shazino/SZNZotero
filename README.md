# SZNZotero

**Objective-C client for the Zotero API.**

> _This is still in early stages of development, so proceed with caution when using this in a production application.
> Any bug reports, feature requests, or general feedback at this point would be greatly appreciated._

SZNZotero is a [Zotero API](http://www.zotero.org/support/dev/server_api/v2/start) client for iOS and Mac OS X, built on top of [AFNetworking](http://www.github.com/AFNetworking/AFNetworking).

## Getting Started

### Installation

[CocoaPods](http://cocoapods.org) is the recommended way to add SZNZotero to your project. CocoaPods is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like SZNZotero in your projects.

Here’s an example podfile that installs SZNZotero and all its dependencies. 

```ruby
platform :ios, '5.0'

pod 'SZNZotero', '~> 0.3.2'
```

### OAuth callback URL

The Zotero API v2 uses [3leg OAuth 1.0](http://www.zotero.org/support/dev/server_api/v2/oauth) authentication. In order to gain access to protected resources, your application will open Mobile Safari and prompt for user credentials. iOS will then switch back to your application using a custom URL scheme. It means that you need to set it up in your Xcode project.

- Open the project editor, select your main target, click the Info button.
- Add a URL Type, and type a unique URL scheme (for instance ’myzoteroclient’).
- Update your app delegate to notify SZNZotero as following:

```objective-c
#import "AFOAuth1Client.h"

NSString * const SZNURLScheme = @"##my_URL_scheme##";

(…)

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.scheme isEqualToString:SZNURLScheme]) {
        NSNotification *notification = [NSNotification notificationWithName:kAFApplicationLaunchedWithURLNotification object:nil userInfo:@{kAFApplicationLaunchOptionsURLKey: url}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    return YES;
}
```

### App credentials

You need to instanciate the Zotero API client with your API consumer key and secret:

```objective-c
NSString *clientKey    = @"###my_consumer_key###";
NSString *clientSecret = @"###my_consumer_secret###";
    
SZNZoteroAPIClient *client = [[SZNZoteroAPIClient alloc] initWithKey:clientKey secret:clientSecret URLScheme:SZNURLScheme];
```

If you don’t have a consumer key and secret, you must [register your application with Zotero](http://www.zotero.org/oauth/apps).


## Examples

### How to fetch the top items in a collection

```objective-c
SZNCollection *parentCollection = ...;

[parentCollection fetchTopItemsSuccess:^(NSArray *items) {
     /* ... */
} failure:^(NSError *error) {
    /* ... */
}];
```

### How to create a new item

```objective-c
SZNLibrary *library = ...;
NSDictionary *itemFields = ...;

[SZNItem createItemInLibrary:library content:itemFields success:^(SZNItem *newItem) {
     /* ... */
} failure:^(NSError *error) {
    /* ... */
}];
```

## References

- [Documentation](http://cocoadocs.org/docsets/SZNZotero/)
- [Changelog](https://github.com/shazino/SZNZotero/wiki/Changelog)
- [Contribute](https://github.com/shazino/SZNZotero/blob/master/CONTRIBUTING.md)

## Requirements

SZNZotero requires Xcode 4.4 with either the iOS 5.0 or Mac OS X 10.7, as well as [AFNetworking](https://github.com/AFNetworking/AFNetworking), [AFOAuth1Client](https://github.com/AFNetworking/AFOAuth1Client), [TBXML](http://www.tbxml.co.uk/TBXML/TBXML_Free.html), and [ISO8601DateFormatter](https://bitbucket.org/boredzo/iso-8601-parser-unparser/). SZNZotero uses [ARC](https://developer.apple.com/library/ios/#releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html).

## Credits

SZNZotero is developed by [shazino](http://www.shazino.com).

## License

SZNZotero is available under the MIT license. See the LICENSE file for more info.
