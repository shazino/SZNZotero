//
// SZNItem.m
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

#import "SZNItem.h"

#import <AFNetworking.h>
#import <TBXML.h>
#import "SZNZoteroAPIClient.h"
#import "SZNTag.h"

@interface SZNItem ()

+ (NSString *)pathToItemsInLibraryWithUserIdentifier:(NSString *)userIdentifier;
+ (NSString *)pathToTopItemsInLibraryWithUserIdentifier:(NSString *)userIdentifier;
- (NSString *)pathToChildItemsWithUserIdentifier:(NSString *)userIdentifier;

@end

@implementation SZNItem

#pragma mark - Parse

+ (SZNItem *)itemFromXMLElement:(TBXMLElement *)XMLElement
{
    SZNItem *item = [SZNItem new];
    item.identifier = [TBXML textForChildElementNamed:@"id" parentElement:XMLElement escaped:NO];
    item.title      = [TBXML textForChildElementNamed:@"title" parentElement:XMLElement escaped:YES];
    item.type       = [TBXML textForChildElementNamed:@"zapi:itemType" parentElement:XMLElement escaped:YES];
    item.key        = [TBXML textForChildElementNamed:@"zapi:key" parentElement:XMLElement escaped:NO];
    
    NSString *JSONContent = [TBXML textForChildElementNamed:@"content" parentElement:XMLElement escaped:NO];
    item.content = [NSJSONSerialization JSONObjectWithData:[JSONContent dataUsingEncoding:NSUTF8StringEncoding]  options:kNilOptions error:nil];
    
    NSMutableSet *tags = [NSMutableSet set];
    for (NSDictionary *tagDictionary in item.content[@"tags"])
    {
        SZNTag *tag = [SZNTag new];
        tag.name = tagDictionary[@"tag"];
        tag.type = [tagDictionary[@"type"] unsignedIntegerValue];
        [tags addObject:tag];
    }
    item.tags = tags;
    
    return item;
}

+ (NSArray *)itemsFromXML:(TBXML *)XML
{
    NSMutableArray *items = [NSMutableArray array];
    [TBXML iterateElementsForQuery:@"entry" fromElement:XML.rootXMLElement withBlock:^(TBXMLElement *XMLElement) {
        [items addObject:[self itemFromXMLElement:XMLElement]];
    }];
    return items;
}

#pragma mark - Fetch

+ (void)fetchItemsInLibraryWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
{
    [client getPath:[self pathToItemsInLibraryWithUserIdentifier:client.userIdentifier] parameters:nil
            success:^(TBXML *XML) { if (success) success([self itemsFromXML:XML]); } failure:failure];
}

+ (void)fetchTopItemsInLibraryWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [client getPath:[self pathToTopItemsInLibraryWithUserIdentifier:client.userIdentifier] parameters:nil
            success:^(TBXML *XML) { if (success) success([self itemsFromXML:XML]); } failure:failure];
}

- (void)fetchChildItemsWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [client getPath:[self pathToChildItemsWithUserIdentifier:client.userIdentifier] parameters:nil
            success:^(TBXML *XML) { if (success) success([SZNItem itemsFromXML:XML]); } failure:failure];
}

#pragma mark - Path

+ (NSString *)pathToItemsInLibraryWithUserIdentifier:(NSString *)userIdentifier
{
    return [NSString stringWithFormat:@"users/%@/items", userIdentifier];
}

+ (NSString *)pathToTopItemsInLibraryWithUserIdentifier:(NSString *)userIdentifier
{
    return [[self pathToItemsInLibraryWithUserIdentifier:userIdentifier] stringByAppendingPathComponent:@"top"];
}

- (NSString *)pathToChildItemsWithUserIdentifier:(NSString *)userIdentifier
{
    return [[[SZNItem pathToItemsInLibraryWithUserIdentifier:userIdentifier] stringByAppendingPathComponent:self.key] stringByAppendingPathComponent:@"children"];
}

@end
