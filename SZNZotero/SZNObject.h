//
// SZNObject.h
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


@class SZNObject, SZNLibrary;

/**
 The `SZNResource` protocol defines the methods for an API resource.
 */
@protocol SZNResource <NSObject>

/**
 The path component for the resource.
 */
+ (nonnull NSString *)pathComponent;

/**
 The key parameter for the resource.
 */
+ (nonnull NSString *)keyParameter;

/**
 Parses objects from an API JSON response array.

 @param JSONArray A representation of the JSON API response.
 @param library The `SZNLibrary` where the objects belong.

 @return An array of newly-created objects.
 */
+ (nullable NSArray *)objectsFromJSONArray:(nullable NSArray *)JSONArray inLibrary:(nonnull SZNLibrary *)library;

/**
 Parses an object from an API JSON response dictionary.

 @param JSONDictionary A representation of the JSON API response.
 @param library The `SZNLibrary` where the objects belong.

 @return A `SZNObject` object.
 */
- (nullable instancetype)initWithJSONDictionary:(nonnull NSDictionary *)JSONDictionary inLibrary:(nonnull SZNLibrary *)library;

@end


/**
 The `SZNItemProtocol` protocol defines the properties an item representation.
 */
@protocol SZNObjectProtocol <NSObject>

/**
 The object creation date.
 */
@property (nonatomic, copy, nonnull) NSDate *creationDate;

/**
 The item content.
 */
@property (nonatomic, strong, nullable) NSDictionary *content;

/**
 The object deleted status.
 */
@property (nonatomic, copy, nullable) NSNumber *deleted;

/**
 The object key.
 */
@property (nonatomic, copy, nonnull) NSString *key;

/**
 The object last modification date.
 */
@property (nonatomic, copy, nonnull) NSDate *modificationDate;

/**
 The object synced status.
 */
@property (nonatomic, copy, nullable) NSNumber *synced;

/**
 The object version.
 */
@property (nonatomic, copy, nonnull) NSNumber *version;

@end


/**
 `SZNObject` is a Zotero object.
 */
@interface SZNObject : NSObject <SZNObjectProtocol, SZNResource>

@property (nonatomic, strong, nullable) SZNLibrary *library;

- (BOOL)isSynced;
- (nonnull NSString *)path;

- (nullable instancetype)initWithJSONDictionary:(nonnull NSDictionary *)JSONDictionary inLibrary:(nonnull SZNLibrary *)library;

@end
