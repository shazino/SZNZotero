//
//  SZNZoteroTests.m
//  SZNZoteroTests
//
//  Created by Vincent Tourraine on 4/25/16.
//  Copyright © 2016 shazino. All rights reserved.
//

@import XCTest;

#import <SZNZotero.h>

@interface SZNZoteroTests : XCTestCase

@end


@implementation SZNZoteroTests

- (void)testExample {
    SZNZoteroAPIClient *client = [[SZNZoteroAPIClient alloc] initWithKey:@"" secret:@"" URLScheme:@""];
    XCTAssertNotNil(client);
}

@end
