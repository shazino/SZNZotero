//
// SZNObject.h
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

@class SZNObject, SZNLibrary;

/**
 The `SZNResource` protocol defines the methods for an API resource.
 */
@protocol SZNResource <NSObject>

/**
 The path component for the resource.
 */
+ (NSString *)pathComponent;

/**
 The key parameter for the resource.
 */
+ (NSString *)keyParameter;

/**
 Parses objects from an API XML response.
 
 @param XML A `TBXML` representation of the API response.
 @param library The `SZNLibrary` where the objects belong.
 
 @return An array of newly-created objects.
 */
+ (NSArray *)objectsFromXML:(TBXML *)XML inLibrary:(SZNLibrary *)library;

/**
 Parses an object from an API XML element.
 
 @param XMLElement A `TBXMLElement` representation of the API response.
 @param library The `SZNLibrary` where the objects belong.
 
 @return A `SZNObject` object.
 */
+ (SZNObject *)objectFromXMLElement:(TBXMLElement *)XMLElement
                          inLibrary:(SZNLibrary *)library;

@end


/**
 The `SZNItemProtocol` protocol defines the properties an item representation.
 */
@protocol SZNObjectProtocol <NSObject>

/**
 The object creation date.
 */
@property (copy, nonatomic) NSDate *creationDate;

/**
 The item content.
 */
@property (strong, nonatomic) NSDictionary *content;

/**
 The object deleted status.
 */
@property (strong, nonatomic) NSNumber *deleted;

/**
 The object key.
 */
@property (copy, nonatomic) NSString *key;

/**
 The object last modification date.
 */
@property (copy, nonatomic) NSDate *modificationDate;

/**
 The object synced status.
 */
@property (strong, nonatomic) NSNumber *synced;

/**
 The object version.
 */
@property (strong, nonatomic) NSNumber *version;

@end


/**
 `SZNObject` is a Zotero object.
 */
@interface SZNObject : NSObject <SZNObjectProtocol, SZNResource>

@property (strong, nonatomic) SZNLibrary *library;

- (BOOL)isSynced;

@end
