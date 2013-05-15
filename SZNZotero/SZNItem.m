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
#import "SZNAuthor.h"


@implementation SZNItemDescriptor

+ (NSSet *)tagsForItem:(id<SZNItemProtocol>)item
{
    NSMutableSet *tags = [NSMutableSet set];
    for (NSDictionary *tagDictionary in item.content[@"tags"])
    {
        SZNTag *tag = [SZNTag new];
        tag.name = tagDictionary[@"tag"];
        tag.type = [tagDictionary[@"type"] integerValue];
        [tags addObject:tag];
    }
    return tags;
}

@end


@interface SZNItem ()

+ (NSString *)pathToItemTypes;
+ (NSString *)pathToValidFields;
+ (NSString *)pathToItemsInLibraryWithUserIdentifier:(NSString *)userIdentifier;
+ (NSString *)pathToTopItemsInLibraryWithUserIdentifier:(NSString *)userIdentifier;
- (NSString *)pathToItemWithUserIdentifier:(NSString *)userIdentifier;
- (NSString *)pathToChildItemsWithUserIdentifier:(NSString *)userIdentifier;
- (NSString *)pathToFileWithUserIdentifier:(NSString *)userIdentifier;

@end


@implementation SZNItem

@synthesize type;
@synthesize content;

- (NSString *)title
{
    return self.content[@"title"];
}

#pragma mark - Parse

+ (SZNItem *)itemFromXMLElement:(TBXMLElement *)XMLElement
{
    NSNumberFormatter *f = [NSNumberFormatter new];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    SZNItem *item = [SZNItem new];
    item.type       = [TBXML textForChildElementNamed:@"zapi:itemType" parentElement:XMLElement escaped:YES];
    item.key        = [TBXML textForChildElementNamed:@"zapi:key" parentElement:XMLElement escaped:NO];
    item.version    = [f numberFromString:[TBXML textForChildElementNamed:@"zapi:version" parentElement:XMLElement escaped:NO]];
    
//    TBXMLElement *authorXMLElement = [TBXML childElementNamed:@"author" parentElement:XMLElement];
//    item.author = [SZNAuthor authorFromXMLElement:authorXMLElement];
    
    NSString *JSONContent = [TBXML textForChildElementNamed:@"content" parentElement:XMLElement escaped:NO];
    item.content = [NSJSONSerialization JSONObjectWithData:[JSONContent dataUsingEncoding:NSUTF8StringEncoding]  options:kNilOptions error:nil];
    
    return item;
}

+ (NSArray *)objectsFromXML:(TBXML *)XML
{
    NSMutableArray *items = [NSMutableArray array];
    [TBXML iterateElementsForQuery:@"entry" fromElement:XML.rootXMLElement withBlock:^(TBXMLElement *XMLElement) {
        [items addObject:[self itemFromXMLElement:XMLElement]];
    }];
    return items;
}

#pragma mark - Create

+ (void)createItemWithClient:(SZNZoteroAPIClient *)client content:(NSDictionary *)content success:(void (^)(SZNItem *))success failure:(void (^)(NSError *))failure
{
    [client postPath:[self pathToItemsInLibraryWithUserIdentifier:client.userIdentifier]
          parameters:@{@"items": @[content]}
            success:^(NSDictionary *responseObject) {
                NSDictionary *successResponse = responseObject[@"success"];
                NSDictionary *failedResponse = responseObject[@"failed"];
                
                if ([failedResponse count] > 0 && failure)
                {
                    NSDictionary *errorDictionary = failedResponse[[failedResponse allKeys][0]];
                    failure([NSError errorWithDomain:@"nil" code:0 userInfo:errorDictionary]);
                }
                else if (success)
                    success(nil);
            }
             failure:failure];
}

#pragma mark - Fetch

+ (void)fetchTypesWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [client getPath:[self pathToItemTypes] parameters:nil success:^(id responseObject) { if (success) success(responseObject); } failure:failure];
}

+ (void)fetchValidFieldsWithClient:(SZNZoteroAPIClient *)client forType:(NSString *)itemType success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [client getPath:[self pathToValidFields] parameters:@{@"itemType": itemType} success:^(id responseObject) { if (success) success(responseObject); } failure:failure];
}

+ (void)fetchItemsInLibraryWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
{
    [client getPath:[self pathToItemsInLibraryWithUserIdentifier:client.userIdentifier]
         parameters:nil
            success:^(TBXML *XML) { if (success) success([self objectsFromXML:XML]); }
            failure:failure];
}

+ (void)fetchTopItemsInLibraryWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [client getPath:[self pathToTopItemsInLibraryWithUserIdentifier:client.userIdentifier]
         parameters:@{@"content": @"json"}
            success:^(TBXML *XML) { if (success) success([self objectsFromXML:XML]); }
            failure:failure];
}

- (void)fetchChildItemsWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [client getPath:[self pathToChildItemsWithUserIdentifier:client.userIdentifier]
         parameters:nil
            success:^(TBXML *XML) { if (success) success([SZNItem objectsFromXML:XML]); }
            failure:failure];
}

- (NSURLRequest *)fileURLRequestWithClient:(SZNZoteroAPIClient *)client
{
    return [client requestWithMethod:@"GET" path:[self pathToFileWithUserIdentifier:client.userIdentifier] parameters:nil];
}

#pragma mark - Update

- (void)updateWithClient:(SZNZoteroAPIClient *)client content:(NSDictionary *)newContent success:(void (^)(SZNItem *))success failure:(void (^)(NSError *))failure;
{
    [client putPath:[self pathToItemWithUserIdentifier:client.userIdentifier]
         parameters:newContent
            success:^(TBXML *XML) { if (success) success(self); }
            failure:failure];
}

- (void)updateWithClient:(SZNZoteroAPIClient *)client partialContent:(NSDictionary *)partialContent success:(void (^)(SZNItem *))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:partialContent];
    mutableParameters[@"itemVersion"] = self.version;
    mutableParameters[@"itemKey"] = self.key;
    mutableParameters[@"itemType"] = self.type;
    [client patchPath:[self pathToItemWithUserIdentifier:client.userIdentifier] parameters:mutableParameters success:^(TBXML *XML) {
        if (success)
            success(self);
    } failure:failure];
}

#pragma mark - Delete

- (void)deleteWithClient:(SZNZoteroAPIClient *)client success:(void (^)())success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    mutableParameters[@"itemVersion"] = self.version;
    [client deletePath:[self pathToItemWithUserIdentifier:client.userIdentifier] parameters:mutableParameters success:^() {
        if (success)
            success();
    } failure:failure];
}

#pragma mark - Path

+ (NSString *)keyParameter
{
    return @"itemKey";
}

+ (NSString *)pathComponent
{
    return @"items";
}

+ (NSString *)pathToItemTypes
{
    return @"/itemTypes";
}

+ (NSString *)pathToValidFields
{
    return @"/itemTypeFields";
}

+ (NSString *)pathToItemsInLibraryWithUserIdentifier:(NSString *)userIdentifier
{
    return [NSString stringWithFormat:@"users/%@/items", userIdentifier];
}

+ (NSString *)pathToTopItemsInLibraryWithUserIdentifier:(NSString *)userIdentifier
{
    return [[self pathToItemsInLibraryWithUserIdentifier:userIdentifier] stringByAppendingPathComponent:@"top"];
}

- (NSString *)pathToItemWithUserIdentifier:(NSString *)userIdentifier
{
    return [[SZNItem pathToItemsInLibraryWithUserIdentifier:userIdentifier] stringByAppendingPathComponent:self.key];
}
     
- (NSString *)pathToChildItemsWithUserIdentifier:(NSString *)userIdentifier
{
    return [[self pathToItemWithUserIdentifier:userIdentifier] stringByAppendingPathComponent:@"children"];
}

- (NSString *)pathToFileWithUserIdentifier:(NSString *)userIdentifier
{
    return [[self pathToItemWithUserIdentifier:userIdentifier] stringByAppendingPathComponent:@"file"];
}

@end
