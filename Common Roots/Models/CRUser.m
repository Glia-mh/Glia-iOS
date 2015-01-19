//
//  CRUser.m
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "CRUser.h"

@implementation CRUser

-(id)initWithID:(NSString *)ID avatarString:(NSString *)aAvatarString name:(NSString *)aName {
    self = [super init];
    if(self) {
        self.userID = ID;
        self.avatarString = aAvatarString;
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:self.userID forKey:@"userID"];
    [encoder encodeObject:self.avatarString forKey:@"avatarString"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(!self ) {
        return nil;
    }
    
    self.userID = [decoder decodeObjectForKey:@"userID"];
    self.avatarString = [decoder decodeObjectForKey:@"avatarString"];
    
    return self;
}

@end
