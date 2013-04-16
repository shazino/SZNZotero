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

@interface AFOAuth1Client ()
- (NSDictionary *)OAuthParameters;
@end

@interface SZNZoteroAPIClient ()
@property (nonatomic, strong) NSString *URLScheme;
@end

@implementation SZNZoteroAPIClient

- (id)initWithKey:(NSString *)key secret:(NSString *)secret URLScheme:(NSString *)URLScheme
{
    self = [super initWithBaseURL:[NSURL URLWithString:@"https://api.zotero.org"] key:key secret:secret];
    if (self)
    {
        self.URLScheme = URLScheme;
        [self setDefaultHeader:@"Zotero-API-Version" value:@"2"];
    }
    return self;
}

- (void)authenticateWithSuccess:(void (^)(AFOAuth1Token *))success failure:(void (^)(NSError *))failure
{
    [self authorizeUsingOAuthWithRequestTokenPath:@"//www.zotero.org/oauth/request"
                            userAuthorizationPath:@"//www.zotero.org/oauth/authorize"
                                      callbackURL:[NSURL URLWithString:[self.URLScheme stringByAppendingString:@"://"]]
                                  accessTokenPath:@"//www.zotero.org/oauth/access" accessMethod:@"GET" success:^(AFOAuth1Token *accessToken) {
        if (success)
            success(accessToken);
    } failure:^(NSError *authError) {
        [self.operationQueue cancelAllOperations];
        self.accessToken = nil;
        if (failure)
            failure(authError);
    }];
}

#pragma mark - Authentication specific steps

- (void)acquireOAuthAccessTokenWithPath:(NSString *)path
                           requestToken:(AFOAuth1Token *)requestToken
                           accessMethod:(NSString *)accessMethod
                                success:(void (^)(AFOAuth1Token *accessToken))success
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
            success(accessToken);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
                [parameters setValue:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }
    
    return parameters;
}


@end
