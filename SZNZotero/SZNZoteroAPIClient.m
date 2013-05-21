//
// SZNZoteroAPIClient.m
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

#import "SZNZoteroAPIClient.h"
#import <AFNetworking.h>
#import <AFOAuth1Client.h>
#import <TBXML.h>
#import "GTMNSString+HTML.h"

@interface AFOAuth1Client ()
- (NSDictionary *)OAuthParameters;
@end


@interface SZNZoteroAPIClient ()

@property (nonatomic, strong) NSString *URLScheme;

- (void)parseResponseWithOperation:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject success:(void (^)(id))success failure:(void (^)(NSError *))failure;

@end


@implementation SZNZoteroAPIClient

- (id)initWithKey:(NSString *)key secret:(NSString *)secret URLScheme:(NSString *)URLScheme
{
    self = [super initWithBaseURL:[NSURL URLWithString:@"https://api.zotero.org"] key:key secret:secret];
    if (self)
    {
        self.URLScheme = URLScheme;
        self.parameterEncoding = AFJSONParameterEncoding;
        [self setDefaultHeader:@"Zotero-API-Version" value:@"2"];
    }
    return self;
}

- (void)authenticateWithSuccess:(void (^)(AFOAuth1Token *))success failure:(void (^)(NSError *))failure
{
    [self authenticateWithLibraryAccess:YES notesAccess:NO writeAccess:NO groupAccessLevel:SZNZoteroAccessNone success:success failure:failure];
}

- (void)authenticateWithLibraryAccess:(BOOL)libraryAccess notesAccess:(BOOL)notesAccess writeAccess:(BOOL)writeAccess groupAccessLevel:(SZNZoteroAccessLevel)groupAccessLevel success:(void (^)(AFOAuth1Token *))success failure:(void (^)(NSError *))failure
{
    [self authorizeUsingOAuthWithRequestTokenPath:@"//www.zotero.org/oauth/request"
                            userAuthorizationPath:[NSString stringWithFormat:@"//www.zotero.org/oauth/authorize?library_access=%d&notes_access=%d&write_access=%d&all_groups=%@",
                                                   libraryAccess, notesAccess, writeAccess,
                                                   (groupAccessLevel == SZNZoteroAccessReadWrite) ? @"write" : (groupAccessLevel == SZNZoteroAccessRead) ? @"read" : @"none" ]
                                      callbackURL:[NSURL URLWithString:[self.URLScheme stringByAppendingString:@"://"]]
                                  accessTokenPath:@"//www.zotero.org/oauth/access" accessMethod:@"GET" scope:@"" success:^(AFOAuth1Token *accessToken, id responseObject) {
                                      if (success)
                                          success(accessToken);
                                  } failure:^(NSError *authError) {
                                      [self.operationQueue cancelAllOperations];
                                      self.accessToken = nil;
                                      if (failure)
                                          failure(authError);
                                  }];
}

- (BOOL)isLoggedIn
{
    return (self.accessToken);
}

- (void)parseResponseWithOperation:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    // NSLog(@"%@", operation.responseString);
    
    NSNumberFormatter *f = [NSNumberFormatter new];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    self.lastModifiedVersion = [f numberFromString:[operation.response allHeaderFields][@"Last-Modified-Version"]];
    
    NSError *error;
    id parsedObject;
    
    if ([operation.response.MIMEType isEqualToString:@"application/json"])
        parsedObject = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
    else
        parsedObject = [TBXML tbxmlWithXMLData:responseObject error:&error];
    
    if (responseObject && error && failure)
        failure(error);
    else if (success)
        success(parsedObject);
}

#pragma mark - AFHTTPClient

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
{
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if ([method isEqualToString:@"GET"])
        requestParameters[@"key"] = self.accessToken.secret;
    else
        path = [path stringByAppendingFormat:@"?key=%@", self.accessToken.secret];
    NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:requestParameters];
    return request;
}

#pragma mark - Methods

- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self parseResponseWithOperation:operation responseObject:responseObject success:success failure:failure];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) failure(error);
    }];
    
    [operation start];
}

- (void)putPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSURLRequest *request = [self requestWithMethod:@"PUT" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self parseResponseWithOperation:operation responseObject:responseObject success:success failure:failure];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) failure(error);
    }];
    
    [operation start];
}

- (void)postPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self parseResponseWithOperation:operation responseObject:responseObject success:success failure:failure];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) failure(error);
    }];
    
    [operation start];
}

- (void)patchPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSURLRequest *request = [self requestWithMethod:@"PATCH" path:path parameters:parameters];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self parseResponseWithOperation:operation responseObject:responseObject success:success failure:failure];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) failure(error);
    }];
    
    [operation start];
}

- (void)deletePath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)())success failure:(void (^)(NSError *))failure
{
    NSNumber *itemVersion = parameters[@"itemVersion"];
    NSMutableURLRequest *request = [self requestWithMethod:@"DELETE" path:path parameters:parameters];
    [request setValue:[itemVersion stringValue] forHTTPHeaderField:@"If-Unmodified-Since-Version"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) failure(error);
    }];
    
    [operation start];
}

#pragma mark - Authentication specific steps

- (void)acquireOAuthAccessTokenWithPath:(NSString *)path
                           requestToken:(AFOAuth1Token *)requestToken
                           accessMethod:(NSString *)accessMethod
                                success:(void (^)(AFOAuth1Token *accessToken, id responseObject))success
                                failure:(void (^)(NSError *error))failure
{
    self.accessToken = requestToken;
    
    NSMutableDictionary *parameters = [[self OAuthParameters] mutableCopy];
    [parameters setValue:requestToken.key forKey:@"oauth_token"];
    [parameters setValue:requestToken.verifier forKey:@"oauth_verifier"];
    
    NSMutableURLRequest *request = [self requestWithMethod:accessMethod path:path parameters:parameters];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            AFOAuth1Token *accessToken = [[AFOAuth1Token alloc] initWithQueryString:operation.responseString];
            NSDictionary *parameters = AFParametersFromQueryString(operation.responseString);
            self.userIdentifier = parameters[@"userID"];
            self.username = parameters[@"username"];
            success(accessToken, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}


static NSDictionary * AFParametersFromQueryString(NSString *queryString)
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (queryString)
    {
        NSScanner *parameterScanner = [[NSScanner alloc] initWithString:queryString];
        NSString *name = nil;
        NSString *value = nil;
        
        while (![parameterScanner isAtEnd])
        {
            name = nil;
            [parameterScanner scanUpToString:@"=" intoString:&name];
            [parameterScanner scanString:@"=" intoString:NULL];
            
            value = nil;
            [parameterScanner scanUpToString:@"&" intoString:&value];
            [parameterScanner scanString:@"&" intoString:NULL];
            
            if (name && value)
            {
                [parameters setValue:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }
    
    return parameters;
}

@end


@implementation TBXML (TextForChild)

+ (NSString *)textForChildElementNamed:(NSString *)childElementName parentElement:(TBXMLElement *)parentElement escaped:(BOOL)escaped
{
    TBXMLElement *element = [TBXML childElementNamed:childElementName parentElement:parentElement];
    if (!element)
        return nil;
    NSString *text = [TBXML textForElement:element];
    return (escaped) ? [text gtm_stringByUnescapingFromHTML] : text;
}

@end
