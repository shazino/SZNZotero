//
// SZNObject.m
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

#import "SZNZoteroAPIClient.h"
#import "SZNLibrary.h"
#import <TBXML.h>
#import <ISO8601DateFormatter.h>

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

+ (NSString *)pathComponent {
    return nil;
}

+ (NSString *)keyParameter {
    return nil;
}

+ (SZNObject *)objectFromXMLElement:(TBXMLElement *)XMLElement
                          inLibrary:(SZNLibrary *)library {
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];

    SZNObject *object = [[self class] new];
    object.key = [TBXML textForChildElementNamed:@"zapi:key" parentElement:XMLElement escaped:NO];

    NSString *versionString          = [TBXML textForChildElementNamed:@"zapi:version" parentElement:XMLElement escaped:NO];
    NSString *creationDateString     = [TBXML textForChildElementNamed:@"published" parentElement:XMLElement escaped:NO];
    NSString *modificationDateString = [TBXML textForChildElementNamed:@"updated" parentElement:XMLElement escaped:NO];
    object.version          = [numberFormatter numberFromString:versionString];
    object.creationDate     = (creationDateString)     ? [dateFormatter dateFromString:creationDateString] : nil;
    object.modificationDate = (modificationDateString) ? [dateFormatter dateFromString:modificationDateString] : nil;
    object.library          = library;

    NSString *JSONContent = [TBXML textForChildElementNamed:@"content" parentElement:XMLElement escaped:NO];
    if (JSONContent) {
        object.content = [NSJSONSerialization JSONObjectWithData:[JSONContent dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:kNilOptions
                                                           error:nil];
    }

    return object;
}

+ (NSArray *)objectsFromXML:(TBXML *)XML inLibrary:(SZNLibrary *)library {
    if (![XML isKindOfClass:TBXML.class]) {
        return @[];
    }

    TBXMLElement *rootXMLElement = XML.rootXMLElement;
    if (!rootXMLElement || !rootXMLElement->firstChild) {
        // With regular Objective-C properties the first condition would be
        // superfluous, but it is necessary here because we’re dealing with
        // struct pointers.
        return @[];
    }

    NSMutableArray *items = [NSMutableArray array];
    if (rootXMLElement->firstChild) {
        [TBXML iterateElementsForQuery:@"entry" fromElement:rootXMLElement withBlock:^(TBXMLElement *XMLElement) {
            SZNObject *object = [self objectFromXMLElement:XMLElement inLibrary:library];
            if (object) {
                [items addObject:object];
            }
        }];
    }
    return items;
}

- (NSString *)path {
    NSString *resourcePath = [self.library pathForResource:[[self class] class]];
    return [resourcePath stringByAppendingPathComponent:self.key];
}

@end
