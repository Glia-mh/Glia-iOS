//
//  CRConversation.m
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "CRConversation.h"

@implementation CRConversation

-(id)initWithParticipants:(NSMutableArray *)aParticipants withConversation:(LYRConversation *)aConversation conversationIdentifier:(NSURL *)conversationID messages:(NSMutableArray *)aMessages latestMessage:(NSString *)lMessage unread:(BOOL)aUnread {
    self = [super init];
    if(self) {
        self.participants = aParticipants;
        self.layerConversation = aConversation;
        self.conversationIdentifier = conversationID;
        self.messages = aMessages;
        self.latestMessage = lMessage;
        self.unread = aUnread;
    }
    return self;
}

@end
