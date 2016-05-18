//
// SZNCollection.m
//
// Copyright (c) 2013-2016 shazino (shazino SAS), http://www.shazino.com/
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


@implementation SZNCollection

#pragma mark - Create

+ (void)createCollectionInLibrary:(nonnull SZNLibrary *)library
                             name:(nonnull NSString *)name
                 parentCollection:(nullable SZNCollection *)parentCollection
                          success:(nullable void (^)(SZNCollection * __nonnull))success
                          failure:(nullable void (^)(NSError * __nullable))failure {
    NSString *path = [library pathForResource:[SZNCollection class]];
    NSDictionary *parameters = @{@"name": name, @"parentCollection" : parentCollection.key ?: @""};

    [library.client
     postPath:path
     parameters:parameters
     headers:nil
     success:^(NSDictionary *responseObject) {
         NSDictionary *successfulResponse = responseObject[@"successful"];
         id successfulResponse0 = [successfulResponse valueForKey:@"0"];

         if (successfulResponse0 != nil && [successfulResponse0 isKindOfClass:[NSDictionary class]]) {
             if (success) {
                 SZNCollection *collection = (SZNCollection *)[[self alloc] initWithJSONDictionary:successfulResponse0 inLibrary:library];
                 success(collection);
             }
         }
         else {
             if (failure) {
                 NSDictionary *failedResponse  = responseObject[@"failed"];
                 NSDictionary *errorDictionary = [failedResponse valueForKey:@"0"];
                 failure([NSError errorWithDomain:@"nil" code:0 userInfo:errorDictionary]);
             }
         }
     }
     failure:failure];
}

#pragma mark - Fetch

- (void)fetchItemsSuccess:(nullable void (^)(NSArray * __nonnull))success
                  failure:(nullable void (^)(NSError * __nullable))failure {
    NSString *resourcePath = [self.library pathForResource:[SZNCollection class]];
    NSString *path = [NSString stringWithFormat:@"%@/%@/items", resourcePath, self.key];
    [self.library fetchObjectsForResource:[SZNItem class] path:path keys:nil specifier:nil success:success failure:failure];
}

- (void)fetchTopItemsSuccess:(nullable void (^)(NSArray * __nonnull))success
                     failure:(nullable void (^)(NSError * __nullable))failure {
    NSString *resourcePath = [self.library pathForResource:[SZNCollection class]];
    NSString *path = [NSString stringWithFormat:@"%@/%@/items/top", resourcePath, self.key];
    [self.library fetchObjectsForResource:[SZNItem class] path:path keys:nil specifier:nil success:success failure:failure];
}

- (void)fetchSubcollectionsSuccess:(nullable void (^)(NSArray * __nonnull))success
                           failure:(nullable void (^)(NSError * __nullable))failure {
    NSString *resourcePath = [self.library pathForResource:[SZNCollection class]];
    NSString *path = [NSString stringWithFormat:@"%@/%@/collections", resourcePath, self.key];
    [self.library fetchObjectsForResource:[SZNCollection class] path:path keys:nil specifier:nil success:success failure:failure];
}

- (void)fetchTagsSuccess:(nullable void (^)(NSArray * __nonnull))success
                 failure:(nullable void (^)(NSError * __nullable))failure {
    NSString *resourcePath = [self.library pathForResource:[SZNCollection class]];
    NSString *path = [NSString stringWithFormat:@"%@/%@/tags", resourcePath, self.key];
    [self.library fetchObjectsForResource:[SZNTag class] path:path keys:nil specifier:nil success:success failure:failure];
}

#pragma mark - Path

+ (nonnull NSString *)keyParameter {
    return @"collectionKey";
}

+ (nonnull NSString *)pathComponent {
    return @"collections";
}

@end
