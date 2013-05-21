//
// SZNTag.h
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

@class SZNZoteroAPIClient, SZNLibrary;

typedef NS_ENUM(NSInteger, SZNTagType) {
    SZNTagCustom = 0,
    SZNTagShared = 1
};

/**
 `SZNTag` is a Zotero tag.
 */
@interface SZNTag : SZNObject

/**
 The tag name.
 */
@property (copy, nonatomic) NSString *name;

/**
 The tag type.
 */
@property (assign, nonatomic) SZNTagType type;

/**
 Parses a tag from an API XML element.
 
 @param XMLElement A `TBXMLElement` representation of the API response.
 
 @return A `SZNTag` object.
 */
+ (SZNTag *)tagFromXMLElement:(TBXMLElement *)XMLElement;

/**
 Parses tags from an API XML response.
 
 @param XML A `TBXML` representation of the API response.
 
 @return An array of `SZNTag` objects.
 */
+ (NSArray *)tagsFromXML:(TBXML *)XML;

/**
 Fetches all tags in the current user library.
 
 @param client The API client to be used to send the fetch request.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: an array of `SZNTag` objects created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
+ (void)fetchTagsInLibrary:(SZNLibrary *)library withClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;

@end
