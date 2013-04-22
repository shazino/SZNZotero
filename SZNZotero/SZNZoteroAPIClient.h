//
// SZNZoteroAPIClient.h
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

#import "AFOAuth1Client.h"
#import <TBXML.h>

typedef NS_ENUM(NSUInteger, SZNZoteroAccessLevel) {
    SZNZoteroAccessNone,
    SZNZoteroAccessRead,
    SZNZoteroAccessReadWrite
};

/**
 `SZNZoteroAPIClient` is an HTTP client preconfigured for accessing Zotero API.
 */
@interface SZNZoteroAPIClient : AFOAuth1Client

/**
 The Altmetric identifier for the current user.
 */
@property (copy, nonatomic) NSString *userIdentifier;

/**
 The Altmetric username for the current user.
 */
@property (copy, nonatomic) NSString *username;

/**
 Whether the client is currently logged in.
 */
@property (readonly, getter = isLoggedIn) BOOL loggedIn;

/**
 Initializes an `SZNZoteroAPIClient` object with the specified API key, secret, and URL scheme.
 
 @param key The API key.
 @param secret The API secret.
 @param URLScheme The URL scheme.
 
 @return The newly-initialized client
 */
- (id)initWithKey:(NSString *)key secret:(NSString *)secret URLScheme:(NSString *)URLScheme;

/**
 Authenticates the client with default access level parameters.
 
 @param success A block object to be executed when the authentication operations finish successfully. This block has no return value and takes one argument: the newly-acquired OAuth token.
 @param failure A block object to be executed when the authentication operations finish unsuccessfully, or that finish successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)authenticateWithSuccess:(void (^)(AFOAuth1Token *))success failure:(void (^)(NSError *))failure;

/**
 Authenticates the client with the specified access level parameters.
 
 @param libraryAccess Whether the API should allow read access to personal library items.
 @param notesAccess Whether the API should allow read access to personal library notes.
 @param writeAccess Whether the API should allow write access to personal library.
 @param groupAccessLevel The level of access the API should allow to all current and future groups.
 @param success A block object to be executed when the authentication operations finish successfully. This block has no return value and takes one argument: the newly-acquired OAuth token.
 @param failure A block object to be executed when the authentication operations finish unsuccessfully, or that finish successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)authenticateWithLibraryAccess:(BOOL)libraryAccess notesAccess:(BOOL)notesAccess writeAccess:(BOOL)writeAccess groupAccessLevel:(SZNZoteroAccessLevel)groupAccessLevel success:(void (^)(AFOAuth1Token *))success failure:(void (^)(NSError *))failure;

/**
 Creates an `AFHTTPRequestOperation` with a `GET` request, and enqueues it to the HTTP client’s operation queue.
 
 @param path The path to be appended to the HTTP client’s base URL and used as the request URL.
 @param parameters The parameters to be encoded and appended as the query string for the request URL.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the object `TBXML` created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)getPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(TBXML *))success failure:(void (^)(NSError *))failure;

/**
 Creates an `AFHTTPRequestOperation` with a `PUT` request, and enqueues it to the HTTP client’s operation queue.
 
 @param path The path to be appended to the HTTP client’s base URL and used as the request URL.
 @param parameters The parameters to be encoded and appended as the query string for the request URL.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the object `TBXML` created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)putPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(TBXML *))success failure:(void (^)(NSError *))failure;

/**
 Creates an `AFHTTPRequestOperation` with a `PATCH` request, and enqueues it to the HTTP client’s operation queue.
 
 @param path The path to be appended to the HTTP client’s base URL and used as the request URL.
 @param parameters The parameters to be encoded and appended as the query string for the request URL.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes one argument: the object `TBXML` created from the response data of request.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)patchPath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(TBXML *))success failure:(void (^)(NSError *))failure;

/**
 Creates an `AFHTTPRequestOperation` with a `DELETE` request, and enqueues it to the HTTP client’s operation queue.
 
 @param path The path to be appended to the HTTP client’s base URL and used as the request URL.
 @param parameters The parameters to be encoded and appended as the query string for the request URL.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes no argument.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes one argument: the `NSError` object describing the network or parsing error that occurred.
 */
- (void)deletePath:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)())success failure:(void (^)(NSError *))failure;

@end


@interface TBXML (TextForChild)

+ (NSString *)textForChildElementNamed:(NSString *)childElementName parentElement:(TBXMLElement *)parentElement escaped:(BOOL)escaped;

@end
