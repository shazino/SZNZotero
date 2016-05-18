//
// SZNItemField.m
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

#import "SZNItemField.h"

@implementation SZNItemField

+ (nullable instancetype)itemFieldWithResponseDictionary:(nonnull NSDictionary *)responseDictionary {
    NSString *field = responseDictionary[@"field"];
    NSString *localized = responseDictionary[@"localized"];

    if (field == nil || localized == nil) {
        return nil;
    }

    return [[self alloc] initWithField:field localizedName:localized];
}

- (nonnull instancetype)initWithField:(nonnull NSString *)field
                        localizedName:(nonnull NSString *)localizedName {
    self = [super init];

    if (self) {
        self.field = field;
        self.localizedName = localizedName;
    }

    return self;
}

@end
