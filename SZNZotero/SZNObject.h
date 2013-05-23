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

@protocol SZNResource <NSObject>

+ (NSString *)pathComponent;
+ (NSString *)keyParameter;

/**
 Parses objects from an API XML response.
 
 @param XML A `TBXML` representation of the API response.
 
 @return An array of newly-created objects.
 */
+ (NSArray *)objectsFromXML:(TBXML *)XML inLibrary:(SZNLibrary *)library;

/**
 Parses an object from an API XML element.
 
 @param XMLElement A `TBXMLElement` representation of the API response.
 
 @return A `SZNObject` object.
 */
+ (SZNObject *)objectFromXMLElement:(TBXMLElement *)XMLElement inLibrary:(SZNLibrary *)library;

@end


@protocol SZNObjectProtocol <NSObject>

/**
 The item content.
 */
@property (strong, nonatomic) NSDictionary *content;

/**
 The object deleted status.
 */
@property (nonatomic, strong) NSNumber *deleted;

/**
 The object key.
 */
@property (nonatomic, copy) NSString *key;

/**
 The object synced status.
 */
@property (nonatomic, strong) NSNumber *synced;

/**
 The object version.
 */
@property (nonatomic, strong) NSNumber *version;

@end


/**
 `SZNObject` is a Zotero object.
 */
@interface SZNObject : NSObject <SZNObjectProtocol, SZNResource>

@property (strong, nonatomic) SZNLibrary *library;

- (BOOL)isSynced;

@end
