//
// SZNItem.h
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

@class SZNZoteroAPIClient, SZNLibrary, SZNTag, SZNItemType, SZNItemField;

/**
 The `SZNItemProtocol` protocol defines the properties an item representation.
 */
@protocol SZNItemProtocol <SZNObjectProtocol>

/**
 The item type.
 */
@property (nonatomic, copy, nullable) NSString *type;

@end


@interface SZNItemDescriptor : NSObject

+ (nonnull NSSet <SZNTag *> *)tagsForItem:(nonnull id<SZNItemProtocol>)item;

@end


/**
 `SZNItem` is a Zotero item.
 */
@interface SZNItem : SZNObject <SZNItemProtocol>

/**
 Creates a new item.
 
 @param library The item’s library.
 @param content The item content.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: an array of `NSDictionary` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
+ (void)createItemInLibrary:(nonnull SZNLibrary *)library
                    content:(nonnull NSDictionary *)content
                    success:(nullable void (^)(SZNItem * __nonnull newItem))success
                    failure:(nullable void (^)(NSError * __nullable error))failure;

- (void)fetchUploadAuthorizationForFileAtURL:(nonnull NSURL *)fileURL
                                 contentType:(nonnull NSString *)contentType
                                     success:(nullable void (^)(NSDictionary *__nonnull responseObject, NSString * __nonnull responseMD5))success
                                     failure:(nullable void (^)(NSError * __nullable error))failure;

- (void)uploadFileAtURL:(nonnull NSURL *)fileURL
             withPrefix:(nonnull NSString *)prefix
                 suffix:(nonnull NSString *)suffix
                  toURL:(nonnull NSString *)toURL
            contentType:(nonnull NSString *)contentType
              uploadKey:(nonnull NSString *)uploadKey
                success:(nullable void (^)(void))success
                failure:(nullable void (^)(NSError * __nullable error))failure;

- (void)uploadFileAtURL:(nonnull NSURL *)fileURL
            contentType:(nonnull NSString *)contentType
                success:(nullable void (^)(NSString * __nonnull md5))success
                failure:(nullable void (^)(NSError * __nullable error))failure;

/**
 Fetches all children items under this item.
 
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: an array of `SZNItems` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchChildrenItemsSuccess:(nullable void (^)(NSArray * __nonnull))success
                          failure:(nullable void (^)(NSError * __nullable error))failure;

/**
 Updates item with new content.

 @param newContent The new content key/values.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: the updated `SZNItem` object.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)updateWithContent:(nonnull NSDictionary *)newContent
                  success:(nullable void (^)(SZNItem * __nonnull))success
                  failure:(nullable void (^)(NSError * __nullable error))failure;

/**
 Updates item with partial new content.
 
 @param partialContent The modified content key/values.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: the updated `SZNItem` object.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)updateWithPartialContent:(nonnull NSDictionary *)partialContent
                         success:(nullable void (^)(SZNItem * __nonnull))success
                         failure:(nullable void (^)(NSError * __nullable error))failure;

/**
 Deletes item.
 
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes no argument.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)deleteSuccess:(nullable void (^)())success
              failure:(nullable void (^)(NSError * __nullable error))failure;

/**
 The file URL request for attachment items.
 
 @return A `NSURLRequest` object.
 */
- (nullable NSURLRequest *)fileURLRequest;

@end

