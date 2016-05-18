//
// SZNObject.m
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

#import "SZNObject.h"

#import "SZNZoteroAPIClient.h"
#import "SZNLibrary.h"

#import "ISO8601DateFormatter.h"


@implementation SZNObject

@synthesize creationDate;
@synthesize content;
@synthesize deleted;
@synthesize key;
@synthesize modificationDate;
@synthesize synced;
@synthesize version;

- (BOOL)isSynced {
    return [self.synced boolValue];
}

#pragma mark - Resource

+ (nonnull NSString *)pathComponent {
    NSAssert(NO, @"should be subclassed");
    return @"";
}

+ (nonnull NSString *)keyParameter {
    NSAssert(NO, @"should be subclassed");
    return @"";
}

- (nullable instancetype)initWithJSONDictionary:(nonnull NSDictionary *)JSONDictionary inLibrary:(nonnull SZNLibrary *)library {
    self = [super init];

    if (self) {
        ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
        self.key = JSONDictionary[@"key"];
        self.version = JSONDictionary[@"version"];

        NSString *creationDateString = JSONDictionary[@"meta"][@"created"];
        self.creationDate = (creationDateString) ? [dateFormatter dateFromString:creationDateString] : nil;
        NSString *modificationDateString = JSONDictionary[@"meta"][@"lastModified"];
        self.modificationDate = (modificationDateString) ? [dateFormatter dateFromString:modificationDateString] : nil;

        self.library = library;
        self.content = JSONDictionary[@"data"];
    }
    
    return self;
}

+ (nullable NSArray *)objectsFromJSONArray:(nullable NSArray *)JSONArray inLibrary:(nonnull SZNLibrary *)library {
    if (JSONArray == nil) {
        return nil;
    }

    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *JSONDictionary in JSONArray) {
        if ([JSONDictionary isKindOfClass:[NSDictionary class]] == NO) {
            continue;
        }

        SZNObject *object = [[self alloc] initWithJSONDictionary:JSONDictionary inLibrary:library];
        if (object) {
            [items addObject:object];
        }
    }

    return items;
}

- (NSString *)path {
    NSString *resourcePath = [self.library pathForResource:[[self class] class]];
    return [resourcePath stringByAppendingPathComponent:self.key];
}

@end
