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
@property (nonatomic, copy) NSString *identifier;

/**
 The library version.
 */
@property (nonatomic, strong) NSNumber *version;

@property (nonatomic, strong) NSNumber *lastItemsVersion;
@property (nonatomic, strong) NSNumber *lastCollectionsVersion;

@end


/**
 `SZNLibrary` is a Zotero library.
 */
@interface SZNLibrary : SZNObject <SZNLibraryProtocol>

+ (SZNLibrary *)libraryWithIdentifier:(NSString *)identifier;

/**
 Fetches items versions in the current library.
 
 @param client The API client to be used to send the fetch request.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: a dictionary created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchObjectsVersionsForResource:(Class <SZNResource>)resource
                   newerThanLastVersion:(NSNumber *)lastVersion
                             withClient:(SZNZoteroAPIClient *)client
                                success:(void (^)(NSDictionary *))success
                                failure:(void (^)(NSError *))failure;

- (void)fetchObjectsForResource:(Class <SZNResource>)resource
                           keys:(NSArray *)objectsKeys
                     withClient:(SZNZoteroAPIClient *)client
                        success:(void (^)(NSArray *))success
                        failure:(void (^)(NSError *))failure;

- (void)fetchDeletedDataWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *deletedItemsKeys, NSArray *deletedCollectionsKeys))success failure:(void (^)(NSError *))failure;

- (void)updateItem:(id<SZNItemProtocol>)updatedItem withClient:(SZNZoteroAPIClient *)client success:(void (^)(id<SZNItemProtocol>))success failure:(void (^)(NSError *))failure;
- (void)updateCollection:(id<SZNCollectionProtocol>)updatedCollection withClient:(SZNZoteroAPIClient *)client success:(void (^)(id<SZNCollectionProtocol>))success failure:(void (^)(NSError *))failure;

- (void)deleteObjectsForResource:(Class <SZNResource>)resource
                            keys:(NSArray *)objectsKeys
                      withClient:(SZNZoteroAPIClient *)client
                         success:(void (^)())success
                         failure:(void (^)(NSError *))failure;

- (NSString *)pathPrefix;
- (NSString *)pathForResource:(Class <SZNResource>)resource;

@end
