//
// SZNTag.h
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
@property (nonatomic, copy, nonnull) NSString *name;

/**
 The tag type.
 */
@property (nonatomic, assign) SZNTagType type;


/**
 Initializer.

 @param name The name of the tag.
 @param type The type of the tag.

 @return The newly initialized tag instance.
 */
- (nonnull instancetype)initWithName:(nonnull NSString *)name type:(SZNTagType)type;

@end
