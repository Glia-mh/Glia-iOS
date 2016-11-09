//
//  CRAuthenticationManager.m
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "CRAuthenticationManager.h"
#import "CRUser.h"
#import "CRCounselor.h"
#import "AppDelegate.h"

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
    
    NSDictionary *parameters = @{@"app_id": client.appID, @"userid": self.currentUser.userID, @"nonce": nonce };
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
        [client authenticateWithIdentityToken:identityToken completion:^(LYRIdentity *authenticatedUserID, NSError *error) {
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

- (void)authenticateUserID:(NSString *)userID completionBlock:(void (^)(BOOL authenticated))completionBlock {
#warning implement this user authentication later
    if(/* DISABLES CODE */ (YES)) {
        PFObject *user = [PFObject objectWithClassName:@"General_Student_IDs"];
        [user setObject:userID forKey:@"userID"];
        [user saveInBackground];
        
        completionBlock(YES);
    } else {
        completionBlock(NO);
    }
}

- (void)authenticateLayerWithID:(NSString *)userID client:(LYRClient *)client completionBlock:(void (^)(NSString *authenticatedUserID, NSError *error))completionBlock {
    // If the user is authenticated you don't need to re-authenticate.
    NSLog(@"authenticateLayerWithID is called");
    if (client.authenticatedUser) {
        NSLog(@"Layer Authenticated as User %@", client.authenticatedUser);
        if (completionBlock) completionBlock(client.authenticatedUser, nil);
        return;
    }
    
    /*
     * 1. Request an authentication Nonce from Layer
     */
    [client requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        NSLog(@"Stage one has been entered");
        if (!nonce) {
            NSLog(@"No nonce was found");
            if (completionBlock) {
                completionBlock(@"", error);
            }
            return;
        }
        
        /*
         * 2. Acquire identity Token from Layer Identity Service
         */
        [self requestIdentityTokenForUserID:userID appID:client.appID nonce:nonce completion:^(NSString *identityToken, NSError *error) {
            NSLog(@"Stage two has been entered");
            if (!identityToken) {
                if (completionBlock) {
                    completionBlock(@"", error);
                }
                return;
            }
            
            /*
             * 3. Submit identity token to Layer for validation
             */
            [client authenticateWithIdentityToken:identityToken completion:^(LYRIdentity* authenticatedUserID, NSError *error) {
                if (authenticatedUserID) {
                    if (completionBlock) {
                        completionBlock(authenticatedUserID, nil);
                    }
                    NSLog(@"Layer Authenticated as User: %@", authenticatedUserID);
                } else {
                    completionBlock(@"", error);
                }
            }];
        }];
    }];
}

- (void)requestIdentityTokenForUserID:(NSString *)userID appID:(NSURL *)appID nonce:(NSString *)nonce completion:(void(^)(NSString *identityToken, NSError *error))completion
{
    NSParameterAssert(userID);
    NSParameterAssert(appID);
    NSParameterAssert(nonce);
    NSParameterAssert(completion);
    
    NSURL *identityTokenURL = [NSURL URLWithString:@"https://commonroots-auth.herokuapp.com/authenticate"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:identityTokenURL];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSDictionary *parameters = @{ @"app_id": appID, @"user_id": userID, @"nonce": nonce };
    NSData* requestBody = [NSKeyedArchiver archivedDataWithRootObject:parameters];
    /*NSData *requestBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];*/
    request.HTTPBody = requestBody;
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        // Deserialize the response
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(![responseObject valueForKey:@"error"])
        {
            NSString *identityToken = responseObject[@"identity_token"];
            completion(identityToken, nil);
        }
        else
        {
            NSString *domain = @"commonroots-auth.herokuapp.com";
            NSInteger code = [responseObject[@"status"] integerValue];
            NSDictionary *userInfo =
            @{
              NSLocalizedDescriptionKey: @"Layer Identity Provider Returned an Error.",
              NSLocalizedRecoverySuggestionErrorKey: @"There may be a problem with your APPID."
              };
            
            NSError *error = [[NSError alloc] initWithDomain:domain code:code userInfo:userInfo];
            completion(nil, error);
        }
        
    }] resume];
}

- (void)logoutUserWithClient:(LYRClient *)client completion:(void(^)(NSError *error))completion
{
    [client deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        if(success) {
            [CRAuthenticationManager sharedInstance].currentUser = nil;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
            [defaults setObject:nil forKey:CRCurrentUserKey];
            [defaults synchronize];
            
            completion(nil);
        } else {
            completion(error);
        }
    }];
}

- (NSString *)schoolNameForID:(NSString *)schoolID {
    PFQuery *query = [PFQuery queryWithClassName:@"SchoolIDs"];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    PFObject *school = [query getObjectWithId:schoolID];
    return [school objectForKey:@"SchoolName"];
}

+ (NSString *)schoolID
{
    return [CRAuthenticationManager sharedInstance].currentUser.schoolID;
}

+ (NSString *)schoolName
{
    return [CRAuthenticationManager sharedInstance].currentUser.schoolName;
}

+ (CRUser *)loadCurrentUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:CRCurrentUserKey];
    [CRAuthenticationManager sharedInstance].currentUser = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return [CRAuthenticationManager sharedInstance].currentUser;
}

+ (UIImage *)userImage
{
    if([self userIsCounselor]) {
        return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[CRAuthenticationManager sharedInstance].currentUser.avatarString]]];
    } else {
        return [UIImage imageNamed:@"profile-placeholder"];
    }
}

+ (BOOL)userIsCounselor
{
    return [[CRAuthenticationManager sharedInstance].currentUser isKindOfClass:[CRCounselor class]];
}

@end
