//
// SZNCollection.m
//
// Copyright (c) 2013-2014 shazino (shazino SAS), http://www.shazino.com/
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
#import "TBXML.h"


@implementation SZNCollection

#pragma mark - Parse

+ (SZNObject *)objectFromXMLElement:(TBXMLElement *)XMLElement
                          inLibrary:(SZNLibrary *)library {
    SZNCollection *collection = (SZNCollection *)[super objectFromXMLElement:XMLElement inLibrary:library];
    collection.identifier = [TBXML textForChildElementNamed:@"id" parentElement:XMLElement escaped:NO];
    return collection;
}

#pragma mark - Create

+ (void)createCollectionInLibrary:(SZNLibrary *)library
                             name:(NSString *)name
                 parentCollection:(SZNCollection *)parentCollection
                          success:(void (^)(SZNCollection *))success
                          failure:(void (^)(NSError *))failure
{
    [library.client postPath:[library pathForResource:[SZNCollection class]]
                  parameters:@{@"collections": @[@{@"name": name, @"parentCollection" : parentCollection.key ?: @""}]}
                     headers:nil
                     success:^(NSDictionary *responseObject) {
                         NSDictionary *successResponse = responseObject[@"success"];
                         NSDictionary *failedResponse  = responseObject[@"failed"];
                         
                         if ([failedResponse count] > 0 && failure) {
                             NSDictionary *errorDictionary = failedResponse[[failedResponse allKeys][0]];
                             failure([NSError errorWithDomain:@"nil" code:0 userInfo:errorDictionary]);
                         }
                         else if (success) {
                             SZNCollection *collection = (SZNCollection *)[self objectFromXMLElement:nil inLibrary:library];
                             collection.key = [successResponse valueForKey:@"0"];
                             success(collection);
                         }
                     }
                     failure:failure];
}

#pragma mark - Fetch

- (void)fetchItemsSuccess:(void (^)(NSArray *))success
                  failure:(void (^)(NSError *))failure {
    NSString *resourcePath = [self.library pathForResource:[SZNCollection class]];
    NSString *path = [NSString stringWithFormat:@"%@/%@/items", resourcePath, self.key];
    [self.library fetchObjectsForResource:[SZNItem class] path:path keys:nil specifier:nil success:success failure:failure];
}

- (void)fetchTopItemsSuccess:(void (^)(NSArray *))success
                     failure:(void (^)(NSError *))failure {
    NSString *resourcePath = [self.library pathForResource:[SZNCollection class]];
    NSString *path = [NSString stringWithFormat:@"%@/%@/items/top", resourcePath, self.key];
    [self.library fetchObjectsForResource:[SZNItem class] path:path keys:nil specifier:nil success:success failure:failure];
}

- (void)fetchSubcollectionsSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    NSString *resourcePath = [self.library pathForResource:[SZNCollection class]];
    NSString *path = [NSString stringWithFormat:@"%@/%@/collections", resourcePath, self.key];
    [self.library fetchObjectsForResource:[SZNCollection class] path:path keys:nil specifier:nil success:success failure:failure];
}

- (void)fetchTagsSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    NSString *resourcePath = [self.library pathForResource:[SZNCollection class]];
    NSString *path = [NSString stringWithFormat:@"%@/%@/tags", resourcePath, self.key];
    [self.library fetchObjectsForResource:[SZNTag class] path:path keys:nil specifier:nil success:success failure:failure];
}

#pragma mark - Path

+ (NSString *)keyParameter {
    return @"collectionKey";
}

+ (NSString *)pathComponent {
    return @"collections";
}

@end
