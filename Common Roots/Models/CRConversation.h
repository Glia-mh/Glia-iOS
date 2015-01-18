//
//  CRConversation.h
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CRUser.h"
#import <LayerKit/LayerKit.h>

@interface CRConversation : NSObject

@property (nonatomic, strong) LYRConversation *layerConversation;
@property (nonatomic, strong) NSURL *conversationIdentifier;
@property (nonatomic, strong) NSMutableArray *participants;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSString *latestMessage;
@property (nonatomic) BOOL unread;

- (id)initWithParticipants:(NSMutableArray *)aParticipants withConversation:(LYRConversation *)aConversation conversationIdentifier:(NSURL *)conversationID messages:(NSMutableArray *)aMessages latestMessage:(NSString *)lMessage unread:(BOOL)aUnread;

@end
