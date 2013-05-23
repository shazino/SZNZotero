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
#import <SZNZotero.h>

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

- (NSString *)path;

@end


@implementation SZNItem

@synthesize type;
@synthesize content;

- (NSString *)title
{
    return self.content[@"title"];
}

#pragma mark - Parse

+ (SZNObject *)objectFromXMLElement:(TBXMLElement *)XMLElement
                          inLibrary:(SZNLibrary *)library
{
    SZNItem *item = (SZNItem *)[super objectFromXMLElement:XMLElement inLibrary:library];
    item.type     = item.content[@"itemType"];
    return item;
}

#pragma mark - Create

+ (void)createItemInLibrary:(SZNLibrary *)library
                    content:(NSDictionary *)content
                    success:(void (^)(SZNItem *))success
                    failure:(void (^)(NSError *))failure
{
    [library.client postPath:[library pathForResource:[SZNItem class]]
                  parameters:@{@"items": @[content]}
                     success:^(NSDictionary *responseObject) {
                         NSDictionary *successResponse = responseObject[@"success"];
                         NSDictionary *failedResponse  = responseObject[@"failed"];
                         
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

+ (void)fetchTypesWithClient:(SZNZoteroAPIClient *)client
                     success:(void (^)(NSArray *))success
                     failure:(void (^)(NSError *))failure
{
    [client getPath:@"/itemTypes"
         parameters:nil
            success:^(id responseObject) {
                if (success)
                    success(responseObject);
            }
            failure:failure];
}

+ (void)fetchValidFieldsWithClient:(SZNZoteroAPIClient *)client
                           forType:(NSString *)itemType
                           success:(void (^)(NSArray *))success
                           failure:(void (^)(NSError *))failure
{
    [client getPath:@"/itemTypeFields"
         parameters:@{@"itemType": itemType}
            success:^(id responseObject) {
                if (success)
                    success(responseObject);
            }
            failure:failure];
}

+ (void)fetchItemsInLibrary:(SZNLibrary *)library
                    success:(void (^)(NSArray *))success
                    failure:(void (^)(NSError *))failure;
{
    [library.client getPath:[library pathForResource:[SZNItem class]]
                 parameters:nil
                    success:^(TBXML *XML) {
                        if (success)
                            success([self objectsFromXML:XML inLibrary:library]);
                    }
                    failure:failure];
}

+ (void)fetchTopItemsInLibrary:(SZNLibrary *)library
                       success:(void (^)(NSArray *))success
                       failure:(void (^)(NSError *))failure
{
    NSString *resourcePath = [library pathForResource:[SZNItem class]];
    [library.client getPath:[resourcePath stringByAppendingPathComponent:@"top"]
                 parameters:@{@"content": @"json"}
                    success:^(TBXML *XML) {
                        if (success)
                            success([self objectsFromXML:XML inLibrary:library]);
                    }
                    failure:failure];
}

- (void)fetchChildItemsSuccess:(void (^)(NSArray *))success
                       failure:(void (^)(NSError *))failure
{
    [self.library.client getPath:[[self path] stringByAppendingPathComponent:@"child"]
                      parameters:@{@"content": @"json"}
                         success:^(TBXML *XML) {
                             if (success)
                                 success([SZNItem objectsFromXML:XML inLibrary:self.library]);
                         }
                         failure:failure];
}

- (NSURLRequest *)fileURLRequest
{
    NSString *path = [[self path] stringByAppendingPathComponent:@"file"];
    return [self.library.client requestWithMethod:@"GET" path:path parameters:nil];
}

#pragma mark - Update

- (void)updateWithContent:(NSDictionary *)newContent
                  success:(void (^)(SZNItem *))success
                  failure:(void (^)(NSError *))failure;
{
    [self.library.client putPath:[self path]
                      parameters:newContent
                         success:^(TBXML *XML) { if (success) success(self); }
                         failure:failure];
}

- (void)updateWithPartialContent:(NSDictionary *)partialContent
                         success:(void (^)(SZNItem *))success
                         failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *mutableParameters = [partialContent mutableCopy];
    mutableParameters[@"itemVersion"] = self.version;
    mutableParameters[@"itemKey"]     = self.key;
    mutableParameters[@"itemType"]    = self.type;
    [self.library.client patchPath:[self path]
                        parameters:mutableParameters
                           success:^(TBXML *XML) { if (success) success(self); }
                           failure:failure];
}

#pragma mark - Delete

- (void)deleteSuccess:(void (^)())success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    mutableParameters[@"itemVersion"] = self.version;
    [self.library.client deletePath:[self path]
                         parameters:mutableParameters
                            success:^() { if (success) success(); }
                            failure:failure];
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

- (NSString *)path
{
    NSString *resourcePath = [self.library pathForResource:[SZNItem class]];
    return [resourcePath stringByAppendingPathComponent:self.key];
}

@end
