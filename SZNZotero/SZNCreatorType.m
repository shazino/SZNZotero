//
// SZNCreatorType.m
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

#import "SZNCreatorType.h"

#import "SZNZoteroAPIClient.h"
#import "SZNItemType.h"


@implementation SZNCreatorType

#pragma mark - Initializer

- (nonnull instancetype)initWithType:(nonnull NSString *)type
                       localizedName:(nonnull NSString *)localizedName {
    self = [super init];

    if (self) {
        self.type = type;
        self.localizedName = localizedName;
    }

    return self;
}

+ (nullable instancetype)creatorTypeWithResponseDictionary:(nonnull NSDictionary *)responseDictionary {
    NSString *creatorType = responseDictionary[@"creatorType"];
    NSString *localized = responseDictionary[@"localized"];

    if (creatorType == nil || localized == nil) {
        return nil;
    }

    return [[self alloc] initWithType:creatorType localizedName:localized];
}

+ (nonnull NSArray <SZNCreatorType *> *)creatorTypesWithResponseArray:(nonnull NSArray *)responseArray {
    NSMutableArray *creatorTypes = [[NSMutableArray alloc] initWithCapacity:[responseArray count]];

    for (NSDictionary *rawCreatorType in responseArray) {
        if ([rawCreatorType isKindOfClass:[NSDictionary class]] == NO) {
            continue;
        }

        SZNCreatorType *creatorType = [SZNCreatorType creatorTypeWithResponseDictionary:rawCreatorType];
        if (creatorType) {
            [creatorTypes addObject:creatorType];
        }
    }

    return creatorTypes;
}

#pragma mark - Fetch

+ (void)fetchValidCreatorTypesWithClient:(nonnull SZNZoteroAPIClient *)client
                             forItemType:(nonnull SZNItemType *)itemType
                                 success:(nonnull void (^)(NSArray <SZNCreatorType *> * __nonnull validCreatorTypes))success
                                 failure:(nullable void (^)(NSError * __nullable error))failure {
    NSString *path = @"/itemTypeCreatorTypes";
    NSDictionary *parameters = @{@"itemType": itemType.type};

    [client
     getPath:path
     parameters:parameters
     success:^(id responseObject) {
         if ([responseObject isKindOfClass:NSArray.class] == NO) {
             if (failure) {
                 failure(nil);
             }

             return;
         }

         NSArray *creatorTypes = [self creatorTypesWithResponseArray:responseObject];
         success(creatorTypes);
    } failure:failure];
}

@end
