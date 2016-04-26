//
//  SZNZoteroTestsOSX.m
//  SZNZoteroTestsOSX
//
//  Created by Vincent Tourraine on 4/26/16.
//  Copyright © 2016 shazino. All rights reserved.
//

@import XCTest;

#import <SZNZotero.h>

@interface SZNZoteroTestsOSX : XCTestCase

@end


@implementation SZNZoteroTestsOSX

- (void)testExample {
    SZNZoteroAPIClient *client = [[SZNZoteroAPIClient alloc] initWithKey:@"" secret:@"" URLScheme:@""];
    XCTAssertNotNil(client);
}

@end
