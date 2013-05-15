//
// SZNLibrary.m
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

#import "SZNLibrary.h"
#import "SZNZoteroAPIClient.h"
#import "SZNItem.h"

@interface SZNLibrary ()
- (NSString *)itemsPath;
- (NSString *)deletedDataPath;
- (NSString *)pathForResource:(Class <SZNResource>)resource;

- (void)fetchObjectsForResource:(Class <SZNResource>)resource
                           keys:(NSMutableArray *)objectsKeys
              downloadedObjects:(NSMutableArray *)downloadedObjects
                     withClient:(SZNZoteroAPIClient *)client
                        success:(void (^)(NSArray *))success
                        failure:(void (^)(NSError *))failure;

@end


@implementation SZNLibrary

@synthesize identifier;
@synthesize version;
@synthesize lastItemsVersion;

#pragma mark - Requests

- (void)fetchObjectsVersionsForResource:(Class <SZNResource>)resource
                   newerThanLastVersion:(NSNumber *)lastVersion
                             withClient:(SZNZoteroAPIClient *)client
                                success:(void (^)(NSDictionary *))success
                                failure:(void (^)(NSError *))failure
{
    [client getPath:[self pathForResource:resource]
         parameters:@{@"newer": lastVersion ?: @(0), @"format": @"versions"}
            success:^(id responseObject) { if (success) success([responseObject isKindOfClass:[NSDictionary class]] ? responseObject : nil); }
            failure:failure];
}

- (void)fetchObjectsForResource:(Class <SZNResource>)resource
                           keys:(NSMutableArray *)objectsKeys
              downloadedObjects:(NSMutableArray *)downloadedObjects
                     withClient:(SZNZoteroAPIClient *)client
                        success:(void (^)(NSArray *))success
                        failure:(void (^)(NSError *))failure
{
    const NSUInteger batchLimit = 50;
    NSArray *batchOfKeys = [objectsKeys subarrayWithRange:NSMakeRange(0, MIN(batchLimit, [objectsKeys count]))];
    
    [client getPath:[self pathForResource:resource]
         parameters:@{@"content": @"json", [resource keyParameter]: [batchOfKeys componentsJoinedByString:@","]}
            success:^(TBXML *XML) {
                [downloadedObjects addObjectsFromArray:[resource objectsFromXML:XML]];
                [objectsKeys removeObjectsInArray:batchOfKeys];
                
                if ([objectsKeys count] > 0)
                    [self fetchObjectsForResource:resource keys:objectsKeys downloadedObjects:downloadedObjects withClient:client success:success failure:failure];
                else if (success)
                    success(downloadedObjects);
            }
            failure:failure];
}

- (void)fetchObjectsForResource:(Class <SZNResource>)resource
                           keys:(NSArray *)objectsKeys
                     withClient:(SZNZoteroAPIClient *)client
                        success:(void (^)(NSArray *))success
                        failure:(void (^)(NSError *))failure
{
    [self fetchObjectsForResource:resource
                             keys:[NSMutableArray arrayWithArray:objectsKeys]
                downloadedObjects:[NSMutableArray array]
                       withClient:client
                          success:success
                          failure:failure];
}

- (void)fetchDeletedDataWithClient:(SZNZoteroAPIClient *)client success:(void (^)(NSArray *deletedItemsKeys))success failure:(void (^)(NSError *))failure
{
    [client getPath:[self deletedDataPath]
         parameters:@{@"newer": @"0"}
            success:^(NSDictionary *deletedData) {
                if (success)
                    success(deletedData[@"items"]);
            } failure:failure];
}

- (void)updateItem:(id<SZNItemProtocol>)updatedItem withClient:(SZNZoteroAPIClient *)client success:(void (^)(id<SZNItemProtocol>))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:updatedItem.content];
    mutableParameters[@"itemVersion"] = updatedItem.version;
    mutableParameters[@"itemKey"]     = updatedItem.key;
    mutableParameters[@"itemType"]    = updatedItem.type;
    [client patchPath:[[self itemsPath] stringByAppendingPathComponent:updatedItem.key] parameters:mutableParameters success:^(id responseObject) {
        updatedItem.synced  = @YES;
        updatedItem.version = client.lastModifiedVersion;
        if (success)
            success(updatedItem);
    } failure:failure];
}

- (void)deleteObjectsForResource:(Class <SZNResource>)resource
                            keys:(NSArray *)objectsKeys
                      withClient:(SZNZoteroAPIClient *)client
                         success:(void (^)())success
                         failure:(void (^)(NSError *))failure
{
    // TODO: use batch for 50+ objects
    if ([objectsKeys count] >= 50)
    {
        NSLog(@"%s", __PRETTY_FUNCTION__);
        NSLog(@"[!] Warning: cannot delete more than 50 objects");
    }
    
    [client deletePath:[self pathForResource:resource] parameters:@{[resource keyParameter]: [objectsKeys componentsJoinedByString:@","]} success:success failure:failure];
}

#pragma mark - Path

- (NSString *)pathPrefix
{
    return nil;
}

- (NSString *)pathForResource:(Class <SZNResource>)resource
{
    return [[self pathPrefix] stringByAppendingPathComponent:[resource pathComponent]];
}

- (NSString *)itemsPath
{
    return [[self pathPrefix] stringByAppendingPathComponent:@"items"];
}

- (NSString *)deletedDataPath
{
    return [[self pathPrefix] stringByAppendingPathComponent:@"deleted"];
}

@end
