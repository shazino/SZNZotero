//
// SZNZoteroAPIClient.m
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

#import "SZNZoteroAPIClient.h"
#import "AFNetworking.h"
#import "AFOAuth1Client.h"
#import <CommonCrypto/CommonDigest.h>


@interface AFOAuth1Client ()
- (NSDictionary *)OAuthParameters;
@end


@interface SZNZoteroAPIClient ()

@property (nonatomic, copy) NSString *URLScheme;
@property (nonatomic, strong) id applicationLaunchObserver;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, assign) BOOL isRetryingRequest;

@end


@implementation SZNZoteroAPIClient

- (nonnull instancetype)initWithKey:(nonnull NSString *)key
                             secret:(nonnull NSString *)secret
                          URLScheme:(nonnull NSString *)URLScheme {
    self = [super initWithBaseURL:[NSURL URLWithString:@"https://api.zotero.org"] key:key secret:secret];

    if (self) {
        self.URLScheme = URLScheme;
        self.parameterEncoding = AFJSONParameterEncoding;
        [self setDefaultHeader:@"Zotero-API-Version" value:@"3"];

        self.numberFormatter = [NSNumberFormatter new];
        [self.numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    }

    return self;
}

- (void)resetObserver {
    if (self.applicationLaunchObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.applicationLaunchObserver];
    }
}

- (void)authenticateSuccess:(void (^)(AFOAuth1Token *))success
                    failure:(void (^)(NSError *))failure {
    [self authenticateWithLibraryAccess:YES
                            notesAccess:NO
                            writeAccess:NO
                       groupAccessLevel:SZNZoteroAccessNone
               webAuthorizationCallback:nil
                                success:success
                                failure:failure];
}

- (void)authenticateWithLibraryAccess:(BOOL)libraryAccess
                          notesAccess:(BOOL)notesAccess
                          writeAccess:(BOOL)writeAccess
                     groupAccessLevel:(SZNZoteroAccessLevel)groupAccessLevel
             webAuthorizationCallback:(void (^)(NSURL *))webAuthorizationCallback
                              success:(void (^)(AFOAuth1Token *))success
                              failure:(void (^)(NSError *))failure {
    NSString *userAuthorizationPath = [NSString stringWithFormat:@"//www.zotero.org/oauth/authorize?library_access=%d&notes_access=%d&write_access=%d&all_groups=%@",
                                       libraryAccess, notesAccess, writeAccess,
                                       (groupAccessLevel == SZNZoteroAccessReadWrite) ? @"write" : (groupAccessLevel == SZNZoteroAccessRead) ? @"read" : @"none"];
    NSURL *callbackURL = [NSURL URLWithString:[self.URLScheme stringByAppendingString:@"://"]];

    [self authorizeUsingOAuthWithRequestTokenPath:@"//www.zotero.org/oauth/request"
                            userAuthorizationPath:userAuthorizationPath
                                      callbackURL:callbackURL
                                  accessTokenPath:@"//www.zotero.org/oauth/access"
                                     accessMethod:@"GET"
                                            scope:@""
                         webAuthorizationCallback:webAuthorizationCallback
                                          success:^(AFOAuth1Token *accessToken) {
                                              if (success) {
                                                  success(accessToken);
                                              }
                                          }
                                          failure:^(NSError *authError) {
                                              [self.operationQueue cancelAllOperations];
                                              self.accessToken = nil;
                                              if (failure) {
                                                  failure(authError);
                                              }
                                          }];
}

- (void)authorizeUsingOAuthWithRequestTokenPath:(NSString *)requestTokenPath
                          userAuthorizationPath:(NSString *)userAuthorizationPath
                                    callbackURL:(NSURL *)callbackURL
                                accessTokenPath:(NSString *)accessTokenPath
                                   accessMethod:(NSString *)accessMethod
                                          scope:(NSString *)scope
                       webAuthorizationCallback:(void (^)(NSURL *))webAuthorizationCallback
                                        success:(void (^)(AFOAuth1Token *accessToken))success
                                        failure:(void (^)(NSError *error))failure {
    [self acquireOAuthRequestTokenWithPath:requestTokenPath callbackURL:callbackURL accessMethod:(NSString *)accessMethod scope:scope success:^(AFOAuth1Token *requestToken, id responseObject) {
        __block AFOAuth1Token *currentRequestToken = requestToken;
        if (self.applicationLaunchObserver) {
            [[NSNotificationCenter defaultCenter] removeObserver:self.applicationLaunchObserver];
        }

        self.applicationLaunchObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kAFApplicationLaunchedWithURLNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
            NSURL *url = [[notification userInfo] valueForKey:kAFApplicationLaunchOptionsURLKey];

            currentRequestToken.verifier = [AFParametersFromQueryString([url query]) valueForKey:@"oauth_verifier"];

            [self acquireOAuthAccessTokenWithPath:accessTokenPath requestToken:currentRequestToken accessMethod:accessMethod success:^(AFOAuth1Token * accessToken, id responseObject) {
                self.accessToken = accessToken;

                if (success) {
                    success(accessToken);
                }
            } failure:^(NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
        }];

        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:requestToken.key forKey:@"oauth_token"];
        NSURL *requestURL = [[self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"%@&oauth_token=%@", userAuthorizationPath, requestToken.key] parameters:nil] URL];

        if (webAuthorizationCallback) {
            webAuthorizationCallback(requestURL);
        }
        else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED
            [[UIApplication sharedApplication] openURL:requestURL];
#else
            [[NSWorkspace sharedWorkspace] openURL:requestURL];
#endif
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (NSString *)authorizationHeaderForMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters {
    return [NSString stringWithFormat:@"Bearer %@", self.accessToken.key];
}

- (BOOL)isLoggedIn {
    return (self.accessToken != nil);
}

#pragma mark -

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:parameters];

    // POST requests body for the Zotero API must have an array as the root object
    // (isn’t possible with the default AFNetworking implementation)
    if (parameters != nil && [method isEqualToString:@"POST"] && [path hasSuffix:@"/file"] == NO) {
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:@[parameters] options:(NSJSONWritingOptions)0 error:nil]];
    }

    return request;
}

- (void)parseResponseWithOperation:(nullable AFHTTPRequestOperation *)operation
                    responseObject:(nullable id)responseObject
                           success:(nonnull void (^)(id __nullable responseObject))success
                           failure:(nonnull void (^)(NSError * __nullable error))failure {
    // NSLog(@"%@", operation.responseString);

    id lastModifiedVersion = operation.response.allHeaderFields[@"Last-Modified-Version"];
    if (lastModifiedVersion) {
        self.lastModifiedVersion = [self.numberFormatter numberFromString:lastModifiedVersion];
    }

    NSError *error;
    NSData *responseData = responseObject;
    id parsedObject = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];

    const BOOL isSuccessful = (parsedObject != nil || responseData.length == 0);

    if (isSuccessful) {
        success(parsedObject);
    }
    else {
        failure(error);
    }
}


#pragma mark - Methods

- (void)getPath:(nonnull NSString *)path
     parameters:(nullable NSDictionary *)parameters
        success:(nonnull void (^)(id __nullable responseObject))success
        failure:(nonnull void (^)(NSError * __nullable error))failure {
    NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.isRetryingRequest = NO;
        [self parseResponseWithOperation:operation responseObject:responseObject success:success failure:failure];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code == NSURLErrorNetworkConnectionLost && !self.isRetryingRequest) {
            self.isRetryingRequest = YES;
            [self getPath:path parameters:parameters success:success failure:failure];
        }
        else {
            self.isRetryingRequest = NO;
            failure(error);
        }
    }];

    [operation start];
}

- (void)putPath:(nonnull NSString *)path
     parameters:(nullable NSDictionary *)parameters
        success:(nonnull void (^)(id __nullable responseObject))success
        failure:(nonnull void (^)(NSError * __nullable error))failure {
    NSURLRequest *request = [self requestWithMethod:@"PUT" path:path parameters:parameters];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.isRetryingRequest = NO;
        [self parseResponseWithOperation:operation responseObject:responseObject success:success failure:failure];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code == NSURLErrorNetworkConnectionLost && !self.isRetryingRequest) {
            self.isRetryingRequest = YES;
            [self putPath:path parameters:parameters success:success failure:failure];
        }
        else {
            self.isRetryingRequest = NO;
            failure(error);
        }
    }];

    [operation start];
}

- (void)postPath:(nonnull NSString *)path
      parameters:(nullable NSDictionary *)parameters
         headers:(nullable NSDictionary *)headers
         success:(nonnull void (^)(id __nullable responseObject))success
         failure:(nonnull void (^)(NSError * __nullable error))failure {
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.isRetryingRequest = NO;
        [self parseResponseWithOperation:operation responseObject:responseObject success:success failure:failure];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code == NSURLErrorNetworkConnectionLost && !self.isRetryingRequest) {
            self.isRetryingRequest = YES;
            [self postPath:path parameters:parameters headers:headers success:success failure:failure];
        }
        else {
            self.isRetryingRequest = NO;
            failure(error);
        }
    }];

    [operation start];
}

- (void)patchPath:(nonnull NSString *)path
       parameters:(nullable NSDictionary *)parameters
          success:(nonnull void (^)(id __nullable responseObject))success
          failure:(nonnull void (^)(NSError * __nullable error))failure {
    NSURLRequest *request = [self requestWithMethod:@"PATCH" path:path parameters:parameters];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.isRetryingRequest = NO;
        [self parseResponseWithOperation:operation responseObject:responseObject success:success failure:failure];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code == NSURLErrorNetworkConnectionLost && !self.isRetryingRequest) {
            self.isRetryingRequest = YES;
            [self patchPath:path parameters:parameters success:success failure:failure];
        }
        else {
            self.isRetryingRequest = NO;
            failure(error);
        }
    }];

    [operation start];
}

- (void)deletePath:(nonnull NSString *)path
        parameters:(nullable NSDictionary *)parameters
           success:(nonnull void (^)())success
           failure:(nonnull void (^)(NSError * __nullable error))failure {
    NSNumber *itemVersion = parameters[@"itemVersion"];
    NSMutableURLRequest *request = [self requestWithMethod:@"DELETE" path:path parameters:parameters];
    [request setValue:[itemVersion stringValue] forHTTPHeaderField:@"If-Unmodified-Since-Version"];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.isRetryingRequest = NO;
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.code == NSURLErrorNetworkConnectionLost && !self.isRetryingRequest) {
            self.isRetryingRequest = YES;
            [self deletePath:path parameters:parameters success:success failure:failure];
        }
        else {
            self.isRetryingRequest = NO;
            failure(error);
        }
    }];

    [operation start];
}

#pragma mark - Authentication specific steps

- (void)acquireOAuthAccessTokenWithPath:(NSString *)path
                           requestToken:(AFOAuth1Token *)requestToken
                           accessMethod:(NSString *)accessMethod
                                success:(void (^)(AFOAuth1Token *accessToken, id responseObject))success
                                failure:(void (^)(NSError *error))failure {
    self.accessToken = requestToken;

    NSMutableDictionary *parameters = [[self OAuthParameters] mutableCopy];
    [parameters setValue:requestToken.key forKey:@"oauth_token"];
    [parameters setValue:requestToken.verifier forKey:@"oauth_verifier"];

    NSMutableURLRequest *request = [self requestWithMethod:accessMethod path:path parameters:parameters];

    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          if (success) {
                                                                              AFOAuth1Token *accessToken = [[AFOAuth1Token alloc] initWithQueryString:operation.responseString];
                                                                              NSDictionary *parameters = AFParametersFromQueryString(operation.responseString);
                                                                              self.userIdentifier = parameters[@"userID"];
                                                                              self.username = parameters[@"username"];
                                                                              success(accessToken, responseObject);
                                                                          }
                                                                      }
                                                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          if (failure) {
                                                                              failure(error);
                                                                          }
                                                                      }];
    
    [self enqueueHTTPRequestOperation:operation];
}

static NSDictionary * AFParametersFromQueryString(NSString *queryString) {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (queryString) {
        NSScanner *parameterScanner = [[NSScanner alloc] initWithString:queryString];
        NSString *name = nil;
        NSString *value = nil;

        while (![parameterScanner isAtEnd]) {
            name = nil;
            [parameterScanner scanUpToString:@"=" intoString:&name];
            [parameterScanner scanString:@"=" intoString:NULL];

            value = nil;
            [parameterScanner scanUpToString:@"&" intoString:&value];
            [parameterScanner scanString:@"&" intoString:NULL];

            if (name && value) {
                [parameters setValue:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                              forKey:[name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }

    return parameters;
}

@end


@implementation NSData (SZNMD5)

- (nonnull NSString *)MD5 {
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(self.bytes, (CC_LONG)self.length, md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", md5Buffer[i]];
    }

    return output;
}

@end


@implementation NSString (SZNURLEncoding)

- (nonnull NSString *)szn_URLEncodedString {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    NSUInteger sourceLen = strlen((const char *)source);

    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        }
        else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        }
        else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }

    return output;
}

@end
