//
//  CRUser.h
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import <Parse/Parse.h>

@interface CRUser : NSObject

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *avatarString;

-(id)initWithID:(NSString *)ID avatarString:(NSString *)aAvatarString;

- (CRUser *)currentUser;

@end
