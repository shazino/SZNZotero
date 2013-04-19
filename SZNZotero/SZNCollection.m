//
// SZNCollection.m
//
// Copyright (c) 2013 shazino (shazino SAS), http://www.shazino.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SZNCollection.h"
#import "SZNItem.h"
#import "SZNZoteroAPIClient.h"
#import <TBXML.h>

@interface SZNCollection ()

+ (NSString *)pathToCollectionsInLibraryWithUserIdentifier:(NSString *)userIdentifier;
- (NSString *)pathToItemsWithUserIdentifier:(NSString *)userIdentifier;

@end


@implementation SZNCollection

#pragma mark - Parse

+ (NSArray *)collectionsFromXML:(TBXML *)XML
{
    NSMutableArray *collections = [NSMutableArray array];
    [TBXML iterateElementsForQuery:@"entry" fromElement:XML.rootXMLElement withBlock:^(TBXMLElement *entry) {
        SZNCollection *collection = [SZNCollection new];
        collection.identifier   = [TBXML textForChildElementNamed:@"id" parentElement:entry escaped:NO];
        collection.title        = [TBXML textForChildElementNamed:@"title" parentElement:entry escaped:YES];
        collection.key          = [TBXML textForChildElementNamed:@"zapi:key" parentElement:entry escaped:NO];
        [collections addObject:collection];
    }];
    return collections;
}

#pragma mark - Fetch

+ (void)fetchCollectionsInLibraryWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [client getPath:[self pathToCollectionsInLibraryWithUserIdentifier:client.userIdentifier] parameters:nil
            success:^(TBXML *XML) { if (success) success([self collectionsFromXML:XML]); } failure:failure];
}

- (void)fetchItemsWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [client getPath:[self pathToItemsWithUserIdentifier:client.userIdentifier] parameters:nil
            success:^(TBXML *XML) { if (success) success([SZNItem itemsFromXML:XML]); } failure:failure];
}

#pragma mark - Path

+ (NSString *)pathToCollectionsInLibraryWithUserIdentifier:(NSString *)userIdentifier
{
    return [[@"users" stringByAppendingPathComponent:userIdentifier] stringByAppendingPathComponent:@"collections"];
}

- (NSString *)pathToItemsWithUserIdentifier:(NSString *)userIdentifier
{
    return [NSString stringWithFormat:@"users/%@/collections/%@/items/", userIdentifier, self.key];
}

@end
