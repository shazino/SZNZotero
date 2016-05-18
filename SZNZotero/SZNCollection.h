//
// SZNCollection.h
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


@class SZNZoteroAPIClient, SZNLibrary;

@protocol SZNCollectionProtocol <SZNObjectProtocol>

@end


/**
 `SZNCollection` is a Zotero collection.
 */
@interface SZNCollection : SZNObject <SZNCollectionProtocol>

/**
 Creates a new collection.
 
 @param library The collection’s library.
 @param name The collection name.
 @param parentCollection The parent collection.
 @param success A block object to be executed when the request operation finishes successfully.
 This block has no return value and takes one argument: an array of `NSDictionary` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data.
 This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
+ (void)createCollectionInLibrary:(nonnull SZNLibrary *)library
                             name:(nonnull NSString *)name
                 parentCollection:(nullable SZNCollection *)parentCollection
                          success:(nullable void (^)(SZNCollection * __nonnull))success
                          failure:(nullable void (^)(NSError * __nullable))failure;

/**
 Fetches all items in the collection.
 
 @param success A block object to be executed when the request operation finishes successfully.
  This block has no return value and takes one argument: an array of `SZNItems` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, 
  or that finishes successfully, but encountered an error while parsing the response data.
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchItemsSuccess:(nullable void (^)(NSArray * __nonnull))success
                  failure:(nullable void (^)(NSError * __nullable))failure;

/**
 Fetches all top-level items in the collection.
 
 @param success A block object to be executed when the request operation finishes successfully.
  This block has no return value and takes one argument: an array of `SZNItems` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, 
  or that finishes successfully, but encountered an error while parsing the response data.
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchTopItemsSuccess:(nullable void (^)(NSArray * __nonnull))success
                     failure:(nullable void (^)(NSError * __nullable))failure;

/**
 Fetches all subcollections within the collection.
 
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: an array of `SZNCollection` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, 
  or that finishes successfully, but encountered an error while parsing the response data.
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchSubcollectionsSuccess:(nullable void (^)(NSArray * __nonnull))success
                           failure:(nullable void (^)(NSError * __nullable))failure;

/**
 Fetches all tags within the collection.
 
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: an array of `SZNTag` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, 
  or that finishes successfully, but encountered an error while parsing the response data.
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchTagsSuccess:(nullable void (^)(NSArray * __nonnull))success
                 failure:(nullable void (^)(NSError * __nullable))failure;

@end
