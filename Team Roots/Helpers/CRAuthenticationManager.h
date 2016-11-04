//
//  CRAuthenticationManager.h
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "CRUser.h"

static NSString *CRCurrentUserKey = @"CRCurrentUserKey";

@interface CRAuthenticationManager : NSObject <LYRClientDelegate>

@property (nonatomic) CRUser *currentUser;

+ (CRAuthenticationManager *)sharedInstance;

+ (CRUser *)loadCurrentUser;

+ (UIImage *)userImage;

+ (NSString *)schoolID;

+ (NSString *)schoolName;

+ (BOOL)userIsCounselor;

- (NSString *)schoolNameForID:(NSString *)schoolID;



- (void)authenticateUserID:(NSString *)userID completionBlock:(void (^)(BOOL authenticated))completionBlock;

- (void)authenticateLayerWithID:(NSString *)userID client:(LYRClient *)client completionBlock:(void (^)(NSString *authenticatedUserID, NSError *error))completionBlock;

- (void)logoutUserWithClient:(LYRClient *)client completion:(void(^)(NSError *error))completion;

@end

