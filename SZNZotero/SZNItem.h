//
// SZNItem.h
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
#import <TBXML.h>

@class SZNZoteroAPIClient, SZNAuthor, SZNLibrary;

/**
 The `SZNItemProtocol` protocol defines the properties an item representation.
 */
@protocol SZNItemProtocol <SZNObjectProtocol>

/**
 The item type.
 */
@property (copy, nonatomic) NSString *type;

@end


@interface SZNItemDescriptor : NSObject

+ (NSSet *)tagsForItem:(id<SZNItemProtocol>)item;

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
+ (void)createItemInLibrary:(SZNLibrary *)library
                    content:(NSDictionary *)content
                    success:(void (^)(SZNItem *))success
                    failure:(void (^)(NSError *))failure;

/**
 Fetches all item types.
 
 @param client The API client to be used to send the fetch request.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: an array of `NSDictionary` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
+ (void)fetchTypesWithClient:(SZNZoteroAPIClient *)client
                     success:(void (^)(NSArray *))success
                     failure:(void (^)(NSError *))failure;

/**
 Fetches all valid fields for an item type.
 
 @param client The API client to be used to send the fetch request.
 @param itemType The item type.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: an array of `NSDictionary` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
+ (void)fetchValidFieldsWithClient:(SZNZoteroAPIClient *)client
                           forType:(NSString *)itemType
                           success:(void (^)(NSArray *))success
                           failure:(void (^)(NSError *))failure;

+ (void)fetchAttachmentItemTemplateWithClient:(SZNZoteroAPIClient *)client
                                     linkMode:(NSString *)linkMode
                                      success:(void (^)(NSDictionary *))success
                                      failure:(void (^)(NSError *))failure;

+ (void)fetchTemplateWithClient:(SZNZoteroAPIClient *)client
                        forType:(NSString *)itemType
                        success:(void (^)(NSDictionary *))success
                        failure:(void (^)(NSError *))failure;

- (void)fetchUploadAuthorizationForFileAtURL:(NSURL *)fileURL
                                 contentType:(NSString *)contentType
                                     success:(void (^)(NSDictionary *))success
                                     failure:(void (^)(NSError *))failure;

- (void)uploadFileAtURL:(NSURL *)fileURL
             withPrefix:(NSString *)prefix
                 suffix:(NSString *)suffix
                  toURL:(NSString *)toURL
            contentType:(NSString *)contentType
              uploadKey:(NSString *)uploadKey
                success:(void (^)(void))success
                failure:(void (^)(NSError *))failure;

/**
 Fetches all children items under this item.
 
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: an array of `SZNItems` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)fetchChildrenItemsSuccess:(void (^)(NSArray *))success
                          failure:(void (^)(NSError *))failure;

/**
 Updates item with new content.

 @param newContent The new content key/values.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: the updated `SZNItem` object.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)updateWithContent:(NSDictionary *)newContent
                  success:(void (^)(SZNItem *))success
                  failure:(void (^)(NSError *))failure;

/**
 Updates item with partial new content.
 
 @param partialContent The modified content key/values.
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes one argument: the updated `SZNItem` object.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)updateWithPartialContent:(NSDictionary *)partialContent
                         success:(void (^)(SZNItem *))success
                         failure:(void (^)(NSError *))failure;

/**
 Deletes item.
 
 @param success A block object to be executed when the request operation finishes successfully. 
  This block has no return value and takes no argument.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. 
  This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)deleteSuccess:(void (^)())success failure:(void (^)(NSError *))failure;

/**
 The file URL request for attachment items.
 
 @return A `NSURLRequest` object.
 */
- (NSURLRequest *)fileURLRequest;

@end

