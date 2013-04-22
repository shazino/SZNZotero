//
// SZNCollection.h
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

#import <Foundation/Foundation.h>
#import <TBXML.h>

@class SZNZoteroAPIClient;

/**
 `SZNCollection` is a Zotero collection.
 */
@interface SZNCollection : NSObject

/**
 The collection identifier.
 */
@property (copy, nonatomic) NSString *identifier;

/**
 The collection title.
 */
@property (copy, nonatomic) NSString *title;

/**
 The collection key.
 */
@property (copy, nonatomic) NSString *key;

/**
 Parses a collection from an API XML element.
 
 @param XMLElement A `TBXMLElement` representation of the API response.
 
 @return A `SZNCollection` object.
 */
+ (SZNCollection *)collectionFromXMLElement:(TBXMLElement *)XMLElement;

/**
 Parses collections from an API XML response.
 
 @param XML A `TBXML` representation of the API response.
 
 @return An array of `SZNCollection` objects.
 */
+ (NSArray *)collectionsFromXML:(TBXML *)XML;

/**
 Fetches all collections in the current user library.
 
 @param client The API client to be used to send the fetch request.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: an array of `SZNCollection` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
+ (void)fetchCollectionsInLibraryWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

/**
 Fetches all top-level collections in the current user library.
 
 @param client The API client to be used to send the fetch request.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: an array of `SZNCollection` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
+ (void)fetchTopCollectionsInLibraryWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

/**
 Fetches all items in the collection.
 
 @param client The API client to be used to send the fetch request.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: an array of `SZNItems` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchItemsWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

/**
 Fetches all top-level items in the collection.
 
 @param client The API client to be used to send the fetch request.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: an array of `SZNItems` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchTopItemsWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

/**
 Fetches all subcollections within the collection.
 
 @param client The API client to be used to send the fetch request.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: an array of `SZNCollection` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchSubcollectionsWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

/**
 Fetches all tags within the collection.
 
 @param client The API client to be used to send the fetch request.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: an array of `SZNTag` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchTagsWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

@end
