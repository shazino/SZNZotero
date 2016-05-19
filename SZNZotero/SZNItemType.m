//
// SZNItemType.m
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

#import "SZNItemType.h"

#import "SZNZoteroAPIClient.h"


@implementation SZNItemType

#pragma mark - Initialization

- (nonnull instancetype)initWithType:(nonnull NSString *)type
                       localizedName:(nonnull NSString *)localizedName {
    self = [super init];

    if (self) {
        self.type = type;
        self.localizedName = localizedName;
    }

    return self;
}

+ (nullable instancetype)itemTypeWithResponseDictionary:(nonnull NSDictionary *)responseDictionary {
    NSString *itemType = responseDictionary[@"itemType"];
    NSString *localized = responseDictionary[@"localized"];

    if (itemType == nil || localized == nil) {
        return nil;
    }

    return [[self alloc] initWithType:itemType localizedName:localized];
}

+ (nonnull NSArray <SZNItemType *> *)itemTypesWithResponseArray:(nonnull NSArray *)responseArray {
    NSMutableArray *itemTypes = [[NSMutableArray alloc] initWithCapacity:[responseArray count]];

    for (NSDictionary *rawItemType in responseArray) {
        if ([rawItemType isKindOfClass:[NSDictionary class]] == NO) {
            continue;
        }

        SZNItemType *itemType = [SZNItemType itemTypeWithResponseDictionary:rawItemType];
        if (itemType) {
            [itemTypes addObject:itemType];
        }
    }

    return itemTypes;
}

#pragma mark - Fetch

+ (void)fetchTypesWithClient:(nonnull SZNZoteroAPIClient *)client
                     success:(nonnull void (^)(NSArray <SZNItemType *> * __nonnull))success
                     failure:(nullable void (^)(NSError * __nullable error))failure {
    [client
     getPath:@"/itemTypes"
     parameters:nil
     success:^(id responseObject) {
         if ([responseObject isKindOfClass:NSArray.class] == NO) {
             if (failure) {
                 failure(nil);
             }

             return;
         }

         NSArray *itemTypes = [self itemTypesWithResponseArray:responseObject];
         success(itemTypes);
     }
     failure:failure];
}

+ (void)fetchNewItemTemplateWithClient:(nonnull SZNZoteroAPIClient *)client
                               forType:(nonnull SZNItemType *)itemType
                               success:(nonnull void (^)(NSDictionary * __nonnull responseObject))success
                               failure:(nullable void (^)(NSError * __nullable error))failure {
    NSString *path = @"/items/new";
    NSDictionary *parameters = @{@"itemType": itemType.type};

    [client getPath:path parameters:parameters success:success failure:failure];
}

+ (nonnull NSString *)valueForLinkMode:(SZNAttachmentLinkMode)linkMode {
    switch (linkMode) {
        case SZNAttachmentLinkModeLinkedURL:
            return @"linked_url";

        case SZNAttachmentLinkModeLinkedFile:
            return @"linked_file";

        case SZNAttachmentLinkModeImportedURL:
            return @"imported_url";

        case SZNAttachmentLinkModeImportedFile:
            return @"imported_file";
    }
}

+ (void)fetchNewAttachmentTemplateWithClient:(nonnull SZNZoteroAPIClient *)client
                                    linkMode:(SZNAttachmentLinkMode)linkMode
                                     success:(nonnull void (^)(NSDictionary * __nonnull responseObject))success
                                     failure:(nullable void (^)(NSError * __nullable error))failure {
    NSString *path = @"/items/new";
    NSString *parameters = @{@"itemType": @"attachment", @"linkMode": [self valueForLinkMode:linkMode]};

    [client getPath:path parameters:parameters success:success failure:failure];
}

@end
