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

- (void)testClientInitialization {
    SZNZoteroAPIClient *client = [[SZNZoteroAPIClient alloc] initWithKey:@"" secret:@"" URLScheme:@""];
    XCTAssertNotNil(client);
}

- (void)testParseItemTypeFromAPIResponseObject {
    NSDictionary *responseObject = @{@"itemType": @"book", @"localized": @"Book"};
    SZNItemType *itemType = [SZNItemType itemTypeWithResponseDictionary:responseObject];

    XCTAssertNotNil(itemType);
    XCTAssertEqualObjects(itemType.type, @"book");
    XCTAssertEqualObjects(itemType.localizedName, @"Book");
}

- (void)testParseItemFieldFromAPIResponseObject {
    NSDictionary *responseObject = @{@"field": @"title", @"localized": @"Title" };
    SZNItemField *field = [SZNItemField itemFieldWithResponseDictionary:responseObject];

    XCTAssertNotNil(field);
    XCTAssertEqualObjects(field.field, @"title");
    XCTAssertEqualObjects(field.localizedName, @"Title");
}

- (void)testParseCreatorTypeFromAPIResponseObject {
    NSDictionary *responseObject = @{@"creatorType": @"author", @"localized": @"Author"};
    SZNCreatorType *creatorType = [SZNCreatorType creatorTypeWithResponseDictionary:responseObject];

    XCTAssertNotNil(creatorType);
    XCTAssertEqualObjects(creatorType.type, @"author");
    XCTAssertEqualObjects(creatorType.localizedName, @"Author");
}

@end
