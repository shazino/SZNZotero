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

@implementation SZNCollection

+ (void)fetchCollectionsInLibraryWithClient:(SZNZoteroAPIClient *)client userIdentifier:(NSString *)userIdentifier success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [client getPath:[[@"users" stringByAppendingPathComponent:userIdentifier] stringByAppendingPathComponent:@"collections"]
         parameters:nil
            success:^(TBXML *xml) {
                NSMutableArray *collections = [NSMutableArray array];
                [TBXML iterateElementsForQuery:@"entry" fromElement:xml.rootXMLElement withBlock:^(TBXMLElement *entry) {
                    SZNCollection *collection = [SZNCollection new];
                    collection.title = [TBXML textForChildElementNamed:@"title" parentElement:entry escaped:YES];
                    collection.identifier = [TBXML textForChildElementNamed:@"id" parentElement:entry escaped:NO];
                    collection.key = [TBXML textForChildElementNamed:@"zapi:key" parentElement:entry escaped:NO];
                    [collections addObject:collection];
                }];
                
                if (success)
                    success(collections);
            } failure:failure];
}

- (void)fetchItemsWithClient:(SZNZoteroAPIClient *)client userIdentifier:(NSString *)userIdentifier success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [client getPath:[NSString stringWithFormat:@"users/%@/collections/%@/items/", userIdentifier, self.key]
         parameters:nil
            success:^(TBXML *xml) {
                NSMutableArray *items = [NSMutableArray array];
                [TBXML iterateElementsForQuery:@"entry" fromElement:xml.rootXMLElement withBlock:^(TBXMLElement *entry) {
                    SZNItem *item = [SZNItem new];
                    item.title = [TBXML textForChildElementNamed:@"title" parentElement:entry escaped:YES];
                    item.identifier = [TBXML textForChildElementNamed:@"id" parentElement:entry escaped:NO];
                    [items addObject:item];
                }];
                
                if (success)
                    success(items);
            } failure:failure];
}

@end
