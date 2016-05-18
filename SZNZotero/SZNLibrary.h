//
// SZNLibrary.h
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

@import Foundation;
#import "SZNObject.h"

@class SZNZoteroAPIClient;
@protocol SZNItemProtocol, SZNCollectionProtocol, SZNResource;

/**
 The `SZNLibraryProtocol` protocol defines the properties of a library representation.
 */
@protocol SZNLibraryProtocol <NSObject>

@end


/**
 `SZNLibrary` is a Zotero library.
 */
@interface SZNLibrary : SZNObject <SZNLibraryProtocol>

@property (nonatomic, strong, nonnull) SZNZoteroAPIClient *client;

@property (nonatomic, strong, nullable) void (^progressBlock)(NSUInteger itemsRead, NSUInteger totalItemsRead, NSUInteger totalItemsExpectedToRead);

/**
 Creates a `SZNLibrary` and initializes its identifier and client properties.
 
 @param identifier The library identifier.
 @param client The library client.
 
 @return The newly-initialized library.
 */
- (nonnull instancetype)initWithIdentifier:(nonnull NSString *)identifier
                                    client:(nonnull SZNZoteroAPIClient *)client;

/**
 Fetches resources versions.
 
 @param resource The resource to fetch.
 @param lastVersion The last known resource version.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: a dictionary created from the response data.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchObjectsVersionsForResource:(nonnull Class <SZNResource>)resource
                   newerThanLastVersion:(nullable NSNumber *)lastVersion
                                success:(nullable void (^)(NSDictionary * __nonnull))success
                                failure:(nullable void (^)(NSError * __nullable error))failure;

/**
 Fetches a batch of resources.
 
 @param resource The resource to fetch.
 @param path The relative path of the resources to fetch.
 @param objectsKeys An array of `NSString` corresponding to the keys of resources to fetch.
 @param specifier A string to be added to the main path.
 @param success A block object to be executed when the request operation finishes successfully.
 This block has no return value and takes one argument: an array of objects created from the response data.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data.
 This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchObjectsForResource:(nonnull Class <SZNResource>)resource
                           path:(nullable NSString *)path
                           keys:(nullable NSArray <NSString *> *)objectsKeys
                      specifier:(nullable NSString *)specifier
                        success:(nullable void (^)(NSArray * __nonnull))success
                        failure:(nullable void (^)(NSError * __nullable error))failure;

/**
 Fetches deleted data.
 
 @param success A block object to be executed when the request operation finishes successfully.
 This block has no return value and takes two arguments: an array of `NSString` corresponding to the deleted items keys, and an array of `NSString` corresponding to the deleted collections keys.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data.
 This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchDeletedDataWithSuccess:(nullable void (^)(NSArray * __nonnull deletedItemsKeys, NSArray * __nonnull deletedCollectionsKeys))success
                            failure:(nullable void (^)(NSError * __nullable error))failure;

/**
 Updates an item.
 
 @param updatedItem The item to update.
 @param success A block object to be executed when the request operation finishes successfully.
 This block has no return value and takes one argument: the item updated with the response data.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data.
 This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)updateItem:(nonnull id <SZNItemProtocol>)updatedItem
           success:(nullable void (^)(id <SZNItemProtocol> __nonnull))success
           failure:(nullable void (^)(NSError * __nullable error))failure;

/**
 Updates a collection.
 
 @param updatedCollection The collection to update.
 @param success A block object to be executed when the request operation finishes successfully.
 This block has no return value and takes one argument: the collection updated with the response data.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data.
 This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)updateCollection:(nonnull id <SZNCollectionProtocol>)updatedCollection
                 success:(nullable void (^)(id <SZNCollectionProtocol> __nonnull))success
                 failure:(nullable void (^)(NSError * __nullable error))failure;

/**
 Deletes a batch of resources.
 
 @param resource The resource to delete.
 @param objectsKeys An array of `NSString` corresponding to the keys of resources to delete.
 @param success A block object to be executed when the request operation finishes successfully.
 This block has no return value and takes no argument.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data.
 This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)deleteObjectsForResource:(nonnull Class <SZNResource>)resource
                            keys:(nonnull NSArray <NSString *> *)objectsKeys
                         success:(nullable void (^)())success
                         failure:(nullable void (^)(NSError * __nullable error))failure;

/**
 The path prefix for resources in the library.
 
 @return The path prefix.
 */
- (nonnull NSString *)pathPrefix;

/**
 The path for a resource.
 
 @param resource The resource.
 
 @return The resource path.
 */
- (nonnull NSString *)pathForResource:(nonnull Class <SZNResource>)resource;

@end
