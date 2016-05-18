//
// SZNLibrary.m
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

#import "SZNLibrary.h"
#import "SZNZoteroAPIClient.h"
#import "SZNItem.h"
#import "SZNCollection.h"
#import "SZNObject.h"

@interface SZNLibrary ()

@property (assign, nonatomic) NSUInteger totalNumberOfItems;

@end


@implementation SZNLibrary

- (nonnull instancetype)initWithIdentifier:(nonnull NSString *)identifier client:(nonnull SZNZoteroAPIClient *)client {
    self = [super init];

    if (self) {
        self.key = identifier;
        self.client = client;
    }

    return self;
}

- (nullable instancetype)initWithJSONDictionary:(nonnull NSDictionary *)JSONDictionary inLibrary:(nonnull SZNLibrary *)library {
    self = [super initWithJSONDictionary:JSONDictionary inLibrary:library];

    if (self) {
        NSString *identifier = [JSONDictionary[@"id"] description];
        self.key = identifier;
    }

    return self;
}

#pragma mark - Requests

- (void)fetchObjectsVersionsForResource:(nonnull Class <SZNResource>)resource
                   newerThanLastVersion:(nullable NSNumber *)lastVersion
                                success:(nullable void (^)(NSDictionary * __nonnull))success
                                failure:(nullable void (^)(NSError * __nullable error))failure {
    [self.client
     getPath:[self pathForResource:resource]
     parameters:@{@"newer": lastVersion ?: @(0), @"format": @"versions"}
     success:^(id responseObject) {
         if (success) {
             NSDictionary *responseDictionary = nil;
             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                 responseDictionary = responseObject;
             }

             success(responseDictionary);
         }
     }
     failure:failure];
}

- (void)fetchObjectsForResource:(Class <SZNResource>)resource
                           path:(NSString *)path
                           keys:(NSMutableArray *)objectsKeys
                      specifier:(NSString *)specifier
              downloadedObjects:(NSMutableArray *)downloadedObjects
                        success:(void (^)(NSArray *))success
                        failure:(void (^)(NSError *))failure {
    const NSUInteger batchMaxLimit = 50;
    const NSUInteger batchLimit = batchMaxLimit;
    NSArray *batchOfKeys = [objectsKeys subarrayWithRange:NSMakeRange(0, MIN(batchLimit, [objectsKeys count]))];
    NSDictionary *parameters = [batchOfKeys count] > 0 ? @{[resource keyParameter]: [batchOfKeys componentsJoinedByString:@","]} : nil;

    if (!path) {
        path = [self pathForResource:resource];
        if (specifier) {
            path = [path stringByAppendingPathComponent:specifier];
        }
    }

    [self.client
     getPath:path
     parameters:parameters
     success:^(id responseObject) {
         if ([responseObject isKindOfClass:[NSArray class]] == NO) {
             if (failure) {
                 failure(nil);
             }
             return;
         }

         if (self.progressBlock) {
             self.progressBlock(batchOfKeys.count, self.totalNumberOfItems - objectsKeys.count, self.totalNumberOfItems);
         }

         NSArray *parsedObjects = [resource objectsFromJSONArray:responseObject inLibrary:self];
         for (id object in parsedObjects) {
             if ([object isKindOfClass:[SZNLibrary class]]) {
                 ((SZNLibrary *)object).client = self.client;
             }

             if ([object isKindOfClass:[SZNObject class]]) {
                 ((SZNObject *)object).library = self;
             }
         }

         [downloadedObjects addObjectsFromArray:parsedObjects];
         [objectsKeys removeObjectsInArray:batchOfKeys];

         if ([objectsKeys count] > 0) {
             [self fetchObjectsForResource:resource
                                      path:nil
                                      keys:objectsKeys
                                 specifier:nil
                         downloadedObjects:downloadedObjects
                                   success:success
                                   failure:failure];
         }
         else if (success) {
             success(downloadedObjects);
         }
     }
     failure:failure];
}

- (void)fetchObjectsForResource:(nonnull Class <SZNResource>)resource
                           path:(nullable NSString *)path
                           keys:(nullable NSArray <NSString *> *)objectsKeys
                      specifier:(nullable NSString *)specifier
                        success:(nullable void (^)(NSArray * __nonnull))success
                        failure:(nullable void (^)(NSError * __nullable error))failure {

    if (objectsKeys && objectsKeys.count == 0) {
        if (success) {
            success(@[]);
        }
        return;
    }

    self.totalNumberOfItems = objectsKeys.count;
    if (self.progressBlock) {
        self.progressBlock(0, self.totalNumberOfItems - objectsKeys.count, self.totalNumberOfItems);
    }

    [self fetchObjectsForResource:resource
                             path:path
                             keys:[NSMutableArray arrayWithArray:objectsKeys]
                        specifier:specifier
                downloadedObjects:[NSMutableArray array]
                          success:success
                          failure:failure];
}

- (void)fetchDeletedDataWithSuccess:(nullable void (^)(NSArray * __nonnull deletedItemsKeys, NSArray * __nonnull deletedCollectionsKeys))success
                            failure:(nullable void (^)(NSError * __nullable error))failure {
    [self.client
     getPath:[self deletedDataPath]
     parameters:@{@"newer": self.version ?: @"0"}
     success:^(NSDictionary *deletedData) {
         if (success) {
             NSArray *items = deletedData[@"items"];
             NSArray *collections = deletedData[@"collections"];
             success(items, collections);
         }
     }
     failure:failure];
}

- (void)updateItem:(nonnull id <SZNItemProtocol>)updatedItem
           success:(nullable void (^)(id <SZNItemProtocol> __nonnull))success
           failure:(nullable void (^)(NSError * __nullable error))failure {
    NSMutableDictionary *mutableParameters = [updatedItem.content mutableCopy];

    if (updatedItem.version) {
        mutableParameters[@"itemVersion"] = updatedItem.version;
    }

    if (updatedItem.key) {
        mutableParameters[@"itemKey"] = updatedItem.key;
    }

    if (updatedItem.type) {
        mutableParameters[@"itemType"] = updatedItem.type;
    }

    NSString *path = [[self pathForResource:[SZNItem class]] stringByAppendingPathComponent:updatedItem.key];

    [self.client
     patchPath:path
     parameters:mutableParameters
     success:^(id responseObject) {
         updatedItem.synced  = @YES;
         updatedItem.version = self.client.lastModifiedVersion;

         if (success) {
            success(updatedItem);
         }
     }
     failure:failure];
}

- (void)updateCollection:(nonnull id <SZNCollectionProtocol>)updatedCollection
                 success:(nullable void (^)(id <SZNCollectionProtocol> __nonnull))success
                 failure:(nullable void (^)(NSError * __nullable error))failure {
    NSMutableDictionary *mutableParameters = [updatedCollection.content mutableCopy];

    if (updatedCollection.version) {
        mutableParameters[@"collectionVersion"] = updatedCollection.version;
    }

    if (updatedCollection.key) {
        mutableParameters[@"collectionKey"] = updatedCollection.key;
    }

    NSString *path = [[self pathForResource:[SZNCollection class]] stringByAppendingPathComponent:updatedCollection.key];

    [self.client
     putPath:path
     parameters:mutableParameters
     success:^(id responseObject) {
         updatedCollection.synced  = @YES;
         updatedCollection.version = self.client.lastModifiedVersion;

         if (success) {
             success(updatedCollection);
         }
     }
     failure:failure];
}

- (void)deleteObjectsForResource:(nonnull Class <SZNResource>)resource
                            keys:(nonnull NSArray <NSString *> *)objectsKeys
                         success:(nullable void (^)())success
                         failure:(nullable void (^)(NSError * __nullable error))failure {
    // TODO: use batch for 50+ objects
    if (objectsKeys.count >= 50) {
        NSLog(@"%s", __PRETTY_FUNCTION__);
        NSLog(@"[!] Warning: cannot delete more than 50 objects");
    }

    NSString *path = [self pathForResource:resource];
    NSDictionary *parameters = @{[resource keyParameter]: [objectsKeys componentsJoinedByString:@","]};

    [self.client deletePath:path parameters:parameters success:success failure:failure];
}

#pragma mark - Path

- (nonnull NSString *)pathPrefix {
    NSAssert(NO, @"should be subclassed");
    return @"";
}

- (nonnull NSString *)pathForResource:(Class <SZNResource>)resource {
    return [[self pathPrefix] stringByAppendingPathComponent:[resource pathComponent]];
}

- (nonnull NSString *)deletedDataPath {
    return [[self pathPrefix] stringByAppendingPathComponent:@"deleted"];
}

@end
