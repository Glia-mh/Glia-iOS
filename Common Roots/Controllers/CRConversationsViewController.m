//
//  CRConversationsViewController.m
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "CRConversationsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+Common_Roots.h"

#define PUSH_CHAT_VC_SEGUE @"PushChatVC"
@interface CRConversationsViewController ()

@end

@implementation CRConversationsViewController {
    CRConversation *loadedConversation;
    LYRClient *layerClient;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    layerClient = [CRConversationManager layerClient];
    
    if(self.receivedConversationToLoad) {
        loadedConversation = self.receivedConversationToLoad;
        [self performSegueWithIdentifier:PUSH_CHAT_VC_SEGUE sender:self];
    }
    
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    self.queryController = [layerClient queryControllerWithQuery:query];
    self.queryController.delegate = self;
    NSError *error;
    BOOL success = [self.queryController execute:&error];
    if (success) {
        NSLog(@"Query fetched %tu conversation objects", [self.queryController numberOfObjectsInSection:0]);
        if([CRConversationManager sharedInstance].conversations.count == 0) {
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, self.view.bounds.size.width - 20, 200)];
            
            messageLabel.text = @"Tap the faces above to start talking to a counselor";
            messageLabel.textColor = [UIColor blackColor];
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = NSTextAlignmentCenter;
            messageLabel.font = [UIFont fontWithName:@"Avenir-DemiBold" size:40];
            [messageLabel sizeToFit];
            
            self.conversationsTableView.backgroundView = messageLabel;
            self.conversationsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            [self.conversationsTableView reloadData];
        }
    } else {
        NSLog(@"Query failed with error %@", error);
    }
    
    self.navigationController.navigationBar.translucent = NO;
    self.conversationsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.conversationsTableView reloadData];
    
    [super viewWillAppear:animated];
}

- (id)init {
    if (self=[super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(conversationChange:)
                                                     name:kConversationChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(messageChange:)
                                                     name:kMessageChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)conversationChange:(NSNotification *)notification {
    NSDictionary *changeObject = (NSDictionary *)notification.object;
    NSLog(@"!!!!!!!!!!!!________1!!!!!!! received conversation: %@", changeObject);
    // show notification?
}

- (void)messageChange:(NSNotification *)notification {
    NSDictionary *changeObject = (NSDictionary *)notification.object;
    LYRMessage *message = changeObject[@"object"];
    LYRMessagePart *msgTextPart = [message.parts firstObject];
    LYRMessagePart *revealedPart = [message.parts objectAtIndex:1];
    LYRMessagePart *userPart =[message.parts lastObject];
    BOOL revealed = [[NSKeyedUnarchiver unarchiveObjectWithData:revealedPart.data] boolValue];
    CRUser *msgSender = (CRUser *)[NSKeyedUnarchiver unarchiveObjectWithData:userPart.data];
    NSString *messageText = [[NSString alloc] initWithData:msgTextPart.data encoding:NSUTF8StringEncoding];
    NSString *notificationMessage;
    if(revealed) {
        notificationMessage = [NSString stringWithFormat:@"%@: %@", msgSender.name, messageText];
    } else {
        notificationMessage = [NSString stringWithFormat:@"Anon: %@", messageText];
    }
#warning show local notification
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.queryController numberOfObjectsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Conversation" forIndexPath:indexPath];
    
    LYRConversation *lyrConversation = [self.queryController objectAtIndexPath:indexPath];
    CRConversation *crConversation = [[CRConversationManager sharedInstance] CRConversationForLayerConversation:lyrConversation client:layerClient];
    
    UIImageView *profile = (UIImageView *)[cell viewWithTag: 1];
    profile.layer.cornerRadius = profile.frame.size.width/2;
    profile.layer.masksToBounds = YES;
    
    UILabel *participantNameLabel = (UILabel *)[cell viewWithTag:2];
    
    participantNameLabel.text = crConversation.participant.name;
    [profile sd_setImageWithURL:[NSURL URLWithString:crConversation.participant.avatarString]
                   placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    LYRMessage *latestMessage = crConversation.latestMessage;
    LYRMessagePart *latestMessagePart = latestMessage.parts[0];
    NSString *messageText = [[NSString alloc] initWithData:latestMessagePart.data encoding:NSUTF8StringEncoding];

    UILabel *latestMessageLabel = (UILabel *)[cell viewWithTag:3];
    latestMessageLabel.text = messageText;
    
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:4];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"h:mm a"];
    NSString *dateString = [dateFormat stringFromDate:latestMessage.sentAt];
    timeLabel.text = dateString;
    LYRMessage *lastMessage = [crConversation.messages lastObject];
    
    if(![lastMessage.sentByUserID isEqualToString:[[CRAuthenticationManager sharedInstance] currentUser].userID] && crConversation.unread) {
        participantNameLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:18.0f];
        latestMessageLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
        latestMessageLabel.textColor = [UIColor blackColor];
        timeLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:15.0f];
        timeLabel.textColor = [UIColor unreadBlue];
    } else {
        participantNameLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:18.0f];
        latestMessageLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
        latestMessageLabel.textColor = [UIColor blackColor];
        timeLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:15.0f];
        timeLabel.textColor = [UIColor lightGrayColor];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    loadedConversation = [[CRConversationManager sharedInstance].conversations objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:PUSH_CHAT_VC_SEGUE sender:self];
    [self.conversationsTableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        CRConversation *conversationToDelete = [[CRConversationManager sharedInstance].conversations objectAtIndex:indexPath.row];
        [layerClient deleteConversation:conversationToDelete.layerConversation mode:LYRDeletionModeAllParticipants error:nil];
        [[CRConversationManager sharedInstance].conversations removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"End Chat";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:PUSH_CHAT_VC_SEGUE]) {
        CRChatViewController *chatVC = segue.destinationViewController;
        chatVC.conversation = loadedConversation;
    }
}

- (void)queryControllerWillChangeContent:(LYRQueryController *)queryController
{
    [self.conversationsTableView beginUpdates];
}

- (void)queryController:(LYRQueryController *)controller
        didChangeObject:(id)object
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(LYRQueryControllerChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case LYRQueryControllerChangeTypeInsert:
            [self.conversationsTableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case LYRQueryControllerChangeTypeUpdate:
            [self.conversationsTableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case LYRQueryControllerChangeTypeMove:
            [self.conversationsTableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.conversationsTableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case LYRQueryControllerChangeTypeDelete:
            [self.conversationsTableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)queryControllerDidChangeContent:(LYRQueryController *)queryController
{
    [self.conversationsTableView endUpdates];
}

@end
