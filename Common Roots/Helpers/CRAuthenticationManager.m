//
//  CRAuthenticationManager.m
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "CRAuthenticationManager.h"
#import "CRUser.h"

@implementation CRAuthenticationManager

+ (CRAuthenticationManager *)sharedInstance {
    static CRAuthenticationManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CRAuthenticationManager alloc] init];
    });
    return _sharedInstance;
}

- (void)layerClient:(LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce
{
    NSLog(@"Client Did Receive Authentication Challenge with Nonce %@", nonce);
    NSURL *identityTokenURL = [NSURL URLWithString:@"https://common-roots-auth.herokuapp.com/authenticate"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:identityTokenURL];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSDictionary *parameters = @{@"app_id": [client.appID UUIDString], @"userid": self.currentUser.userID, @"nonce": nonce };
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    request.HTTPBody = requestBody;
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // Deserialize the response
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *identityToken = responseObject[@"identityToken"];
        /*
         * 3. Submit identity token to Layer for validation
         */
        [client authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
            if (!error) {
                NSLog(@"Authenticated as User: %@", authenticatedUserID);
            }
            else {
                NSLog(@"Authentication error as User: %@", authenticatedUserID);
            }
        }];
        
    }] resume];
}

// Called when your application has successfully authenticated a user via LayerKit
- (void)layerClient:(LYRClient *)client didAuthenticateAsUserID:(NSString *)userID
{
    NSLog(@"Client Did Authenticate As %@", userID);
}

// Called when you successfully logout a user via LayerKit
- (void)layerClientDidDeauthenticate:(LYRClient *)client
{
    NSLog(@"Client did de-authenticate the user");
}

- (void)authenticateUserID:(void (^)(BOOL))completionBlock {
#warning implement this later
    completionBlock(YES);
}

- (void)authenticateLayerWithID:(NSString *)userID client:(LYRClient *)client completionBlock:(void (^)(NSString *authenticatedUserID, NSError *error))completionBlock {
    NSString *userIDString = userID;
    
    [client requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        /*
         * 2. Acquire identity Token from Layer Identity Service
         */
        NSURL *identityTokenURL = [NSURL URLWithString:@"https://common-roots-auth.herokuapp.com/authenticate"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:identityTokenURL];
        request.HTTPMethod = @"POST";
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        NSDictionary *parameters = @{@"app_id": [client.appID UUIDString], @"userid": userIDString, @"nonce": nonce };
        NSData *requestBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
        request.HTTPBody = requestBody;
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            // Deserialize the response
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *identityToken = responseObject[@"identityToken"];
            /*
             * 3. Submit identity token to Layer for validation
             */
            [client authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                if (!error) {
                    completionBlock(authenticatedUserID,nil);
                    NSLog(@"Authenticated as User: %@", authenticatedUserID);
                }
                else {
                    completionBlock(nil,error);
                }
            }];
        }] resume];
    }];
}

@end
