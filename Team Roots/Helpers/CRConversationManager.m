//
//  CRConversationManager.m
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "CRConversationManager.h"
#import "CRCounselor.h"

#define LAYER_APP_ID @"e25bc8da-9f52-11e4-97ea-142b010033d0"

NSString * const kConversationChangeNotification = @"ConversationChange";
NSString * const kMessageChangeNotification = @"MessageChange";

@implementation CRConversationManager


+ (CRConversationManager *)sharedInstance {
    static CRConversationManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CRConversationManager alloc] init];
        
    });
    return _sharedInstance;
}

+ (LYRClient *)layerClient {
    static LYRClient *_layerClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *appID = [NSURL URLWithString:@"layer:///apps/staging/ab90d40e-1a6d-11e4-b3d7-a19800003e1b"];
        _layerClient = [LYRClient clientWithAppID:appID delegate:self options:nil];
        NSLog(@"%@", _layerClient);
    });
    return _layerClient;
}

//out of use
- (void)conversationsForLayerClient:(LYRClient *)client completionBlock:(void (^)(NSArray *conversations, NSError *error))completionBlock {
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    
    NSError *error;
    NSOrderedSet *conversations = [client executeQuery:query error:&error];
    if (!error) {
        NSLog(@"Retrieved %tu conversations", conversations.count);
    } else {
        NSLog(@"Query failed with error %@", error);
    }
    
    NSMutableArray *conversationsArray = [[NSMutableArray alloc] init];
    
    for (LYRConversation *lyrConversation in conversations) {
        
        LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
        query.predicate = [LYRPredicate predicateWithProperty:@"conversation" predicateOperator:LYRPredicateOperatorIsEqualTo value:lyrConversation];
        query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
        
        NSError *error;
        NSOrderedSet *messages = [client executeQuery:query error:&error];
        if (!error) {
            NSLog(@"%tu messages in conversation", messages.count);
        } else {
            NSLog(@"Query failed with error %@", error);
        }
        
        LYRMessage *latestMessage = [messages lastObject];

        BOOL unread;
        if(LYRRecipientStatusRead == [latestMessage recipientStatusForUserID:[[CRAuthenticationManager sharedInstance] currentUser].userID])  {
            unread = NO;
        } else {
            unread = YES;
        }
// this value for key is wrong btw
        CRUser *participant = [[CRUser alloc] initWithID:[lyrConversation.metadata valueForKey:@"student.ID"] avatarString:[lyrConversation.metadata valueForKey:@"student.avatarString"] name:[lyrConversation.metadata valueForKey:@"student.name"] schoolID:[CRAuthenticationManager schoolID] schoolName:[CRAuthenticationManager schoolName]];

        CRConversation *crConversation = [[CRConversation alloc] initWithParticipant:participant conversation:lyrConversation messages:messages latestMessage:latestMessage unread:unread];
        
        [conversationsArray addObject:crConversation];
        
        if(conversationsArray.count == conversations.count) {
            NSArray *orderedConversations = [conversationsArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastModified" ascending:NO]]];
            completionBlock(orderedConversations, nil);
        }
    }
}

- (CRConversation *)CRConversationForLayerConversation:(LYRConversation *)lyrConversation client:(LYRClient *)client {
    LYRQuery *messagesQuery = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    messagesQuery.predicate = [LYRPredicate predicateWithProperty:@"conversation" predicateOperator:LYRPredicateOperatorIsEqualTo value:lyrConversation];
    messagesQuery.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
    
    NSError *error;
    NSOrderedSet *messages = [client executeQuery:messagesQuery error:&error];
    
    LYRMessage *latestMessage = [messages lastObject];

    BOOL unread;
    if(LYRRecipientStatusRead == [latestMessage recipientStatusForUserID:[[CRAuthenticationManager sharedInstance] currentUser].userID])  {
        unread = NO;
    } else {
        unread = YES;
    }
   
    CRCounselor *counselor = [[CRCounselor alloc] initWithID:[[lyrConversation.metadata valueForKey:@"counselor"]valueForKey:@"ID"] avatarString:[[lyrConversation.metadata valueForKey:@"counselor"]valueForKey:@"avatarString"] name:[[lyrConversation.metadata valueForKey:@"counselor"]valueForKey:@"name"] bio:[[lyrConversation.metadata valueForKey:@"counselor"]valueForKey:@"bio"] schoolID:[lyrConversation.metadata valueForKey:@"schoolID"] schoolName:[[CRAuthenticationManager sharedInstance] schoolNameForID:[lyrConversation.metadata valueForKey:@"schoolID"]]];
    
    CRConversation *crConversation = [[CRConversation alloc] initWithParticipant:counselor conversation:lyrConversation messages:messages latestMessage:latestMessage unread:unread];
    
    return crConversation;
}

- (void)newConversationWithCounselor:(CRCounselor *)counselor client:(LYRClient *)layerClient completionBlock:(void (^)(CRConversation *conversation, NSError *error))completionBlock {
    NSError *error;
    NSLog(@"%@",counselor.userID);
    
    
#warning todo admin account
    LYRConversation *lyrConversation = [layerClient newConversationWithParticipants:[NSSet setWithObjects:counselor.userID, @"1", nil] options:nil error:&error];
    
    NSDictionary *metadata = @{@"schoolID" : [CRAuthenticationManager schoolID],
                               @"counselor" :
                                    @{
                                       @"name" : counselor.name,
                                       @"ID" : counselor.userID,
                                       @"avatarString" : counselor.avatarString,
                                       @"bio" : counselor.counselorBio},
                               @"student" : @{
                                       @"name" : @"",
                                       @"ID" : [[CRAuthenticationManager sharedInstance] currentUser].userID,
                                       @"avatarString" : [[CRAuthenticationManager sharedInstance] currentUser].avatarString}
                               };
    
    [lyrConversation setValuesForMetadataKeyPathsWithDictionary:metadata merge:YES];
    
    CRConversation *crConversation = [[CRConversation alloc] initWithParticipant:counselor conversation:lyrConversation messages:nil latestMessage:nil unread:NO];
    
    completionBlock(crConversation, nil);
}

- (void)sendMessageToConversation:(CRConversation *)conversation message:(LYRMessage *)message client:(LYRClient *)client completionBlock:(void (^)(NSError *error))completionBlock {
    NSError *error;
    BOOL success = [conversation.layerConversation sendMessage:message error:&error];
    if (success) {
        completionBlock(nil);
    } else {
        completionBlock(error);
    }
}

- (JSQMessage *)jsqMessageForLayerMessage:(LYRMessage *)lyrMessage inConversation:(CRConversation *)conversation{
    LYRMessagePart *part = [lyrMessage.parts firstObject];
    NSString *messageText = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
    
    NSString *senderDisplayName;
#warning to change when making counselor version
    if([lyrMessage.sender.firstName isEqualToString:[[CRAuthenticationManager sharedInstance] currentUser].userID]) {
        senderDisplayName = [[CRAuthenticationManager sharedInstance] currentUser].name;
    } else {
        senderDisplayName = conversation.participant.name;
    }
#warning this is pretty hacky, since jsq reloads messages right after its sent so lyr doenst have a sentat property yet...
    if(lyrMessage.sentAt) {
        return [[JSQMessage alloc] initWithSenderId:lyrMessage.sender.firstName
                                      senderDisplayName:senderDisplayName
                                                   date:lyrMessage.sentAt
                                                   text:messageText];
    } else {
        return [[JSQMessage alloc] initWithSenderId:lyrMessage.sender.firstName
                                      senderDisplayName:senderDisplayName
                                                   date:[NSDate date]
                                                   text:messageText];
    }
}


@end
