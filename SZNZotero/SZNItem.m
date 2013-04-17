//
// SZNItem.m
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

#import "SZNItem.h"

#import <AFNetworking.h>
#import <TBXML.h>
#import "GTMNSString+HTML.h"
#import "SZNZoteroAPIClient.h"

@interface TBXML (TextForChild)

+ (NSString *)textForChildElementNamed:(NSString *)childElementName parentElement:(TBXMLElement *)parentElement escaped:(BOOL)escaped;

@end

@implementation TBXML (TextForChild)

+ (NSString *)textForChildElementNamed:(NSString *)childElementName parentElement:(TBXMLElement *)parentElement escaped:(BOOL)escaped
{
    NSString *text = [TBXML textForElement:[TBXML childElementNamed:childElementName parentElement:parentElement]];
    return (escaped) ? [text gtm_stringByUnescapingFromHTML] : text;
}

@end


@implementation SZNItem

+ (void)fetchItemsInLibraryWithClient:(SZNZoteroAPIClient *)client userIdentifier:(NSString *)userIdentifier success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
{
    [client getPath:[[@"users" stringByAppendingPathComponent:userIdentifier] stringByAppendingPathComponent:@"items"]
         parameters:nil
            success:^(TBXML *xml) {
                NSMutableArray *items = [NSMutableArray array];
                [TBXML iterateElementsForQuery:@"entry" fromElement:xml.rootXMLElement withBlock:^(TBXMLElement *entry) {
                    SZNItem *item = [SZNItem new];
                    item.title = [TBXML textForChildElementNamed:@"title" parentElement:entry escaped:YES];
                    item.identifier= [TBXML textForChildElementNamed:@"id" parentElement:entry escaped:NO];
                    [items addObject:item];
                }];
                
                if (success)
                    success(items);
            } failure:failure];
}

@end
