//
// SZNTag.m
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

#import "SZNTag.h"
#import "SZNZoteroAPIClient.h"

@interface SZNTag ()

+ (NSString *)pathToTagsInLibraryWithUserIdentifier:(NSString *)userIdentifier;

@end


@implementation SZNTag

#pragma mark - Parse

+ (SZNTag *)tagFromXMLElement:(TBXMLElement *)XMLElement
{
    SZNTag *tag = [SZNTag new];
    tag.name = [TBXML textForChildElementNamed:@"title" parentElement:XMLElement escaped:NO];
    return tag;
}

+ (NSArray *)tagsFromXML:(TBXML *)XML
{
    NSMutableArray *tags = [NSMutableArray array];
    [TBXML iterateElementsForQuery:@"entry" fromElement:XML.rootXMLElement withBlock:^(TBXMLElement *XMLElement) {
        [tags addObject:[self tagFromXMLElement:XMLElement]];
    }];
    return tags;
}

#pragma mark - Fetch

+ (void)fetchTagsInLibraryWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [client getPath:[self pathToTagsInLibraryWithUserIdentifier:client.userIdentifier] parameters:nil
            success:^(TBXML *XML) { if (success) success([self tagsFromXML:XML]); } failure:failure];
}

#pragma mark - Path

+ (NSString *)pathToTagsInLibraryWithUserIdentifier:(NSString *)userIdentifier
{
    return [NSString stringWithFormat:@"users/%@/tags", userIdentifier];
}

@end
