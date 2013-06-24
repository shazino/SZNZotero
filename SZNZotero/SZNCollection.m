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
#import "SZNTag.h"
#import "SZNLibrary.h"
#import "SZNZoteroAPIClient.h"
#import <TBXML.h>


@implementation SZNCollection

#pragma mark - Parse

+ (SZNObject *)objectFromXMLElement:(TBXMLElement *)XMLElement
                          inLibrary:(SZNLibrary *)library
{
    SZNCollection *collection = (SZNCollection *)[super objectFromXMLElement:XMLElement inLibrary:library];
    collection.identifier = [TBXML textForChildElementNamed:@"id" parentElement:XMLElement escaped:NO];
    return collection;
}

#pragma mark - Fetch

- (void)fetchItemsSuccess:(void (^)(NSArray *))success
                  failure:(void (^)(NSError *))failure
{
    NSString *resourcePath = [self.library pathForResource:[SZNCollection class]];
    [self.library.client getPath:[NSString stringWithFormat:@"%@/%@/items", resourcePath, self.key]
                      parameters:@{@"content": @"json"}
                         success:^(TBXML *XML) {
                             if (success)
                                 success([SZNItem objectsFromXML:XML inLibrary:self.library]);
                         }
                         failure:failure];
}

- (void)fetchTopItemsSuccess:(void (^)(NSArray *))success
                     failure:(void (^)(NSError *))failure
{
    NSString *resourcePath = [self.library pathForResource:[SZNCollection class]];
    [self.library.client getPath:[NSString stringWithFormat:@"%@/%@/items/top", resourcePath, self.key]
                      parameters:@{@"content": @"json"}
                         success:^(TBXML *XML) {
                             if (success)
                                 success([SZNItem objectsFromXML:XML inLibrary:self.library]);
                         }
                         failure:failure];
}

- (void)fetchSubcollectionsSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    NSString *resourcePath = [self.library pathForResource:[SZNCollection class]];
    [self.library.client getPath:[NSString stringWithFormat:@"%@/%@/collections", resourcePath, self.key]
                      parameters:@{@"content": @"json"}
                         success:^(TBXML *XML) {
                             if (success)
                                 success([SZNCollection objectsFromXML:XML inLibrary:self.library]);
                         }
                         failure:failure];
}

- (void)fetchTagsSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    NSString *resourcePath = [self.library pathForResource:[SZNCollection class]];
    [self.library.client getPath:[NSString stringWithFormat:@"%@/%@/tags", resourcePath, self.key]
                      parameters:@{@"content": @"json"}
                         success:^(TBXML *XML) {
                             if (success)
                                 success([SZNTag objectsFromXML:XML inLibrary:self.library]);
                         }
                         failure:failure];
}

#pragma mark - Path

+ (NSString *)keyParameter
{
    return @"collectionKey";
}

+ (NSString *)pathComponent
{
    return @"collections";
}

@end
