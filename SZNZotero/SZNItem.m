//
// SZNItem.m
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

#import "SZNItem.h"

#import "AFNetworking.h"
#import "SZNZotero.h"
#import "SZNTag.h"


@implementation SZNItemDescriptor

+ (nonnull NSSet <SZNTag *> *)tagsForItem:(nonnull id<SZNItemProtocol>)item {
    NSMutableSet *tags = [NSMutableSet set];

    for (NSDictionary *tagDictionary in item.content[@"tags"]) {
        SZNTag *tag = [[SZNTag alloc] initWithName:tagDictionary[@"tag"]
                                              type:[tagDictionary[@"type"] integerValue]];
        [tags addObject:tag];
    }

    return tags;
}

@end


@interface SZNItem ()

@property (nonatomic, assign) BOOL isRetryingRequest;

@end


@implementation SZNItem

@synthesize type;
@synthesize content;

#pragma mark - Parse

- (nullable instancetype)initWithJSONDictionary:(nonnull NSDictionary *)JSONDictionary inLibrary:(nonnull SZNLibrary *)library {
    self = [super initWithJSONDictionary:JSONDictionary inLibrary:library];

    if (self) {
        self.type = self.content[@"itemType"];
    }

    return self;
}

#pragma mark - Create

+ (void)createItemInLibrary:(SZNLibrary *)library
                    content:(NSDictionary *)content
                    success:(void (^)(SZNItem *))success
                    failure:(void (^)(NSError *))failure {
    [library.client
     postPath:[library pathForResource:[SZNItem class]]
     parameters:content
     headers:nil
     success:^(NSDictionary *responseObject) {
         NSDictionary *successResponse = responseObject[@"success"];
         NSDictionary *failedResponse  = responseObject[@"failed"];

         if ([failedResponse count] > 0 && failure) {
             NSDictionary *errorDictionary = failedResponse[[failedResponse allKeys][0]];
             failure([NSError errorWithDomain:@"nil" code:0 userInfo:errorDictionary]);
         }
         else if (success) {
             NSDictionary *dictionary = nil;
             NSString *key = [successResponse valueForKey:@"0"];
             if (key) {
                 dictionary = @{@"key": key};
             }
             SZNItem *item = (SZNItem *)[[self alloc] initWithJSONDictionary:dictionary inLibrary:library];
             success(item);
         }
     }
     failure:failure];
}

#pragma mark - Fetch

- (void)fetchUploadAuthorizationForFileAtURL:(NSURL *)fileURL
                                 contentType:(NSString *)contentType
                                     success:(void (^)(NSDictionary *, NSString *))success
                                     failure:(void (^)(NSError *))failure
{
    NSString *fileName            = [fileURL.lastPathComponent szn_URLEncodedString];
    NSData *fileData              = [NSData dataWithContentsOfURL:fileURL];
    NSString *md5                 = [fileData MD5];
    NSNumber *fileSizeInBytes     = @([fileData length]);
    NSTimeInterval timeModified   = [[NSDate date] timeIntervalSince1970];
    long long mtimeInMilliseconds = (long long) trunc(timeModified * 1000.0f);
    NSDictionary *headers         = (self.content[@"md5"]) ? @{@"If-Match": self.content[@"md5"]} : @{@"If-None-Match": @"*"};
    
    if (!md5 || !fileData) {
        if (failure) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot fetch upload authorization for file.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No file data or MD5.", nil),
                                       @"fileURL": fileURL ?: @""
                                       };
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                                 code:NSURLErrorFileDoesNotExist
                                             userInfo:userInfo];
            failure(error);
        }
    }
    else {
        NSDictionary *parameters = @{@"md5": md5,
                                     @"filename": fileName,
                                     @"filesize": fileSizeInBytes.stringValue,
                                     @"mtime": [NSString stringWithFormat:@"%lld", mtimeInMilliseconds],
                                     @"contentType": contentType};

        NSString *path = [[self path] stringByAppendingPathComponent:@"file"];
        self.library.client.parameterEncoding = AFFormURLParameterEncoding;

        [self.library.client postPath:path
                           parameters:parameters
                              headers:headers
                              success:^(id responseObject) {
                                  if (success) {
                                      success(responseObject, md5);
                                  }
                              }
                              failure:failure];
        
        self.library.client.parameterEncoding = AFJSONParameterEncoding;
    }
}

- (void)uploadFileAtURL:(NSURL *)fileURL
             withPrefix:(NSString *)prefix
                 suffix:(NSString *)suffix
                  toURL:(NSString *)toURL
            contentType:(NSString *)contentType
              uploadKey:(NSString *)uploadKey
                success:(void (^)(void))success
                failure:(void (^)(NSError *))failure {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:toURL]];
    request.HTTPMethod = @"POST";
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    [body appendData:[prefix dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithContentsOfURL:fileURL]];
    [body appendData:[suffix dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         self.isRetryingRequest = NO;

         NSString *path = [[self path] stringByAppendingPathComponent:@"file"];
         NSDictionary *headers = (self.content[@"md5"]) ? @{@"If-Match": self.content[@"md5"]} : @{@"If-None-Match": @"*"};

         self.library.client.parameterEncoding = AFFormURLParameterEncoding;
         [self.library.client postPath:path
                            parameters:@{@"upload": uploadKey}
                               headers:headers
                               success:^(id response) {
                                   if (success) {
                                       success();
                                   }
                               } failure:failure];

         self.library.client.parameterEncoding = AFJSONParameterEncoding;
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (error.code == NSURLErrorNetworkConnectionLost && !self.isRetryingRequest) {
             self.isRetryingRequest = YES;
             [self uploadFileAtURL:fileURL withPrefix:prefix suffix:suffix toURL:toURL contentType:contentType uploadKey:uploadKey success:success failure:failure];
         }
         else if (failure) {
             self.isRetryingRequest = NO;
             failure(error);
         }
     }];

    [operation start];
}

- (void)uploadFileAtURL:(NSURL *)fileURL
            contentType:(NSString *)contentType
                success:(void (^)(NSString *md5))success
                failure:(void (^)(NSError *error))failure
{
    [self
     fetchUploadAuthorizationForFileAtURL:fileURL
     contentType:contentType
     success:^(NSDictionary *response, NSString *md5) {
         if (!response[@"url"]) {
             if (response[@"exists"]) {
                 if (success)
                     success(md5);
             }
             else {
                 if (failure)
                     failure(nil);
             }
         }
         else {
             [self uploadFileAtURL:fileURL
                        withPrefix:response[@"prefix"]
                            suffix:response[@"suffix"]
                             toURL:response[@"url"]
                       contentType:response[@"contentType"]
                         uploadKey:response[@"uploadKey"]
                           success:^() {
                               if (success)
                                   success(md5);
                           }
                           failure:failure];
         }
     }
     failure:failure];
}

- (void)fetchChildrenItemsSuccess:(void (^)(NSArray *))success
                          failure:(void (^)(NSError *))failure {
    if ([self.type isEqualToString:@"attachment"]) {
        if (failure) {
            failure(nil);
        }
        
        return;
    }

    [self.library.client
     getPath:[[self path] stringByAppendingPathComponent:@"children"]
     parameters:nil
     success:^(id responseObject) {
         if ([responseObject isKindOfClass:[NSArray class]] == NO) {
             if (failure) {
                 failure(nil);
             }
             return;
         }

         if (success) {
             success([SZNItem objectsFromJSONArray:responseObject inLibrary:self.library]);
         }
     }
     failure:failure];
}

- (NSURLRequest *)fileURLRequest {
    NSString *path = [[self path] stringByAppendingPathComponent:@"file"];
    return [self.library.client requestWithMethod:@"GET" path:path parameters:nil];
}

#pragma mark - Update

- (void)updateWithContent:(NSDictionary *)newContent
                  success:(void (^)(SZNItem *))success
                  failure:(void (^)(NSError *))failure {
    [self.library.client putPath:[self path]
                      parameters:newContent
                         success:^(id responseObject) { if (success) success(self); }
                         failure:failure];
}

- (void)updateWithPartialContent:(NSDictionary *)partialContent
                         success:(void (^)(SZNItem *))success
                         failure:(void (^)(NSError *))failure {
    NSMutableDictionary *mutableParameters = [partialContent mutableCopy];
    mutableParameters[@"itemVersion"] = self.version;
    mutableParameters[@"itemKey"]     = self.key;
    mutableParameters[@"itemType"]    = self.type;
    [self.library.client patchPath:[self path]
                        parameters:mutableParameters
                           success:^(id responseObject) { if (success) success(self); }
                           failure:failure];
}

#pragma mark - Delete

- (void)deleteSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionary];
    mutableParameters[@"itemVersion"] = self.version;
    [self.library.client deletePath:[self path]
                         parameters:mutableParameters
                            success:^() { if (success) success(); }
                            failure:failure];
}

#pragma mark - Path

+ (NSString *)keyParameter {
    return @"itemKey";
}

+ (NSString *)pathComponent {
    return @"items";
}

@end
