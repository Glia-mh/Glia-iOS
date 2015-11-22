//
//  CRCounselor.m
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "CRCounselor.h"

@implementation CRCounselor

-(id)initWithID:(NSString *)ID avatarString:(NSString *)aAvatarString name:(NSString *)aName bio:(NSString *)aBio schoolID:(NSString *)schoolID {
    self = [super initWithID:aName avatarString:aAvatarString name:aName schoolID:schoolID];
    if(self) {
        self.counselorBio = aBio;
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:self.userID forKey:@"userID"];
    [encoder encodeObject:self.avatarString forKey:@"avatarString"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.counselorBio forKey:@"bio"];
    [encoder encodeObject:self.schoolID forKey:@"schoolID"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(!self ) {
        return nil;
    }
    
    self.userID = [decoder decodeObjectForKey:@"userID"];
    self.avatarString = [decoder decodeObjectForKey:@"avatarString"];
    self.name = [decoder decodeObjectForKey:@"name"];
    self.counselorBio = [decoder decodeObjectForKey:@"bio"];
    self.schoolID = [decoder decodeObjectForKey:@"schoolID"];
    
    return self;
}
@end
