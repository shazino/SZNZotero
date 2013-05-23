//
// SZNLibrary.h
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

#import "SZNObject.h"

@class SZNZoteroAPIClient;
@protocol SZNItemProtocol, SZNCollectionProtocol, SZNResource;

@protocol SZNLibraryProtocol <NSObject>

/**
 The library identifier.
 */
@property (copy, nonatomic) NSString *identifier;

/**
 The library version.
 */
@property (strong, nonatomic) NSNumber *version;

@property (strong, nonatomic) NSNumber *lastItemsVersion;
@property (strong, nonatomic) NSNumber *lastCollectionsVersion;

@end


/**
 `SZNLibrary` is a Zotero library.
 */
@interface SZNLibrary : SZNObject <SZNLibraryProtocol>

@property (strong, nonatomic) SZNZoteroAPIClient *client;

+ (SZNLibrary *)libraryWithIdentifier:(NSString *)identifier client:(SZNZoteroAPIClient *)client;

/**
 Fetches items versions in the current library.
 
 @param client The API client to be used to send the fetch request.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: a dictionary created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchObjectsVersionsForResource:(Class <SZNResource>)resource
                   newerThanLastVersion:(NSNumber *)lastVersion
                                success:(void (^)(NSDictionary *))success
                                failure:(void (^)(NSError *))failure;

- (void)fetchObjectsForResource:(Class <SZNResource>)resource
                           keys:(NSArray *)objectsKeys
                        success:(void (^)(NSArray *))success
                        failure:(void (^)(NSError *))failure;

- (void)fetchDeletedDataWithSuccess:(void (^)(NSArray *deletedItemsKeys, NSArray *deletedCollectionsKeys))success failure:(void (^)(NSError *))failure;

- (void)updateItem:(id<SZNItemProtocol>)updatedItem success:(void (^)(id<SZNItemProtocol>))success failure:(void (^)(NSError *))failure;
- (void)updateCollection:(id<SZNCollectionProtocol>)updatedCollection success:(void (^)(id<SZNCollectionProtocol>))success failure:(void (^)(NSError *))failure;

- (void)deleteObjectsForResource:(Class <SZNResource>)resource
                            keys:(NSArray *)objectsKeys
                         success:(void (^)())success
                         failure:(void (^)(NSError *))failure;

- (NSString *)pathPrefix;
- (NSString *)pathForResource:(Class <SZNResource>)resource;

@end
