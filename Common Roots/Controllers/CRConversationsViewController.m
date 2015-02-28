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
#import "CRCounselor.h"

#define PUSH_CHAT_VC_SEGUE @"PushChatVC"
#define MODAL_COUNSELORS_VC_SEGUE @"ModalCounselorsVC"

@interface CRConversationsViewController ()

@end

@implementation CRConversationsViewController {
    CRConversation *loadedConversation;
    LYRClient *layerClient;
    UILabel *messageLabel;
    NSMutableArray *counselors;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];

    counselors = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Counselors"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for(int i = 0; i < objects.count; i++){
                CRCounselor *counselor = [[CRCounselor alloc] initWithID:[objects[i] objectForKey:@"userID"] avatarString:[objects[i] objectForKey:@"Photo_URL"] name:[objects[i] objectForKey:@"Name"] bio:[objects[i] objectForKey:@"Bio"]];
                [counselors addObject:counselor];
                [self.counselorsCollectionView reloadData];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    
    layerClient = [CRConversationManager layerClient];
    
    if(self.receivedConversationToLoad) {
        loadedConversation = self.receivedConversationToLoad;
        [self performSegueWithIdentifier:PUSH_CHAT_VC_SEGUE sender:self];
    }
    
    LYRQuery *lyrQuery = [LYRQuery queryWithClass:[LYRConversation class]];
    lyrQuery.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.receivedAt" ascending:NO]];
    self.queryController = [layerClient queryControllerWithQuery:lyrQuery];
    self.queryController.delegate = self;
    
    NSError *error;
    BOOL success = [self.queryController execute:&error];
    if (success) {
        NSLog(@"Query fetched %tu conversation objects", [self.queryController numberOfObjectsInSection:0]);
        if(self.queryController.count > 0) {
            [messageLabel removeFromSuperview];
        
            [self.conversationsTableView reloadData];
        }
    } else {
        NSLog(@"Query failed with error %@", error);
    }
    
    self.navigationController.navigationBar.translucent = NO;
    self.conversationsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(counselorsTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.counselorsCollectionView addGestureRecognizer:tapRecognizer];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableViewRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.conversationsTableView target:self refreshAction:@selector(refreshTriggered:) plist:@"refreshControl" color:[UIColor whiteColor] lineWidth:1.5 dropHeight:80 scale:1 horizontalRandomness:150 reverseLoadingAnimation:YES internalAnimationFactor:0.5];
}

- (void)viewWillAppear:(BOOL)animated{
    NSError *error;
    
    BOOL success = [self.queryController execute:&error];
    if (success) {
        NSLog(@"Query fetched %tu conversation objects", [self.queryController numberOfObjectsInSection:0]);
        if(self.queryController.count == 0) {
            messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, self.view.bounds.size.width - 90, 200)];
            messageLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 30);
            messageLabel.text = @"Tap the faces above to start talking to a counselor. :)";
            messageLabel.textColor = [UIColor lightGrayColor];
            messageLabel.numberOfLines = 4;
            messageLabel.textAlignment = NSTextAlignmentCenter;
            messageLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:25];
            messageLabel.alpha = 0.6;
            [self.view addSubview:messageLabel];
            
            self.conversationsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self.conversationsTableView reloadData];
        }
    } else {
        NSLog(@"Query failed with error %@", error);
    }
    
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
    LYRConversation *conversation = changeObject[@"object"];

}

- (void)messageChange:(NSNotification *)notification {
    NSDictionary *changeObject = (NSDictionary *)notification.object;
    NSLog(@"received message: %@", changeObject);
    
    LYRMessage *message = changeObject[@"object"];
}

- (void)counselorsTapped:(UITapGestureRecognizer*)sender {
    [self performSegueWithIdentifier:MODAL_COUNSELORS_VC_SEGUE sender:self];
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
    LYRConversation *lyrConversation = [self.queryController objectAtIndexPath:indexPath];
    loadedConversation = [[CRConversationManager sharedInstance] CRConversationForLayerConversation:lyrConversation client:layerClient];

    [self performSegueWithIdentifier:PUSH_CHAT_VC_SEGUE sender:self];
    [self.conversationsTableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        LYRConversation *conversationToDelete = [self.queryController objectAtIndexPath:indexPath];
        NSError *error;
        [conversationToDelete delete:LYRDeletionModeAllParticipants error:&error];
        
        if(error) {
            NSLog(@"shit");
        }
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"End Chat";
}

- (void)counselorsViewControllerDismissedWithConversation:(CRConversation *)conversation {
    loadedConversation = conversation;
    [self performSegueWithIdentifier:PUSH_CHAT_VC_SEGUE sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:PUSH_CHAT_VC_SEGUE]) {
        CRChatViewController *chatVC = segue.destinationViewController;
        chatVC.conversation = loadedConversation;
        
    } else if ([segue.identifier isEqualToString:MODAL_COUNSELORS_VC_SEGUE]) {
        UINavigationController *navController = [segue destinationViewController];
        assert([([navController viewControllers][0]) isKindOfClass:[CRCounselorsViewController class]]);
        CRCounselorsViewController *cVC = (CRCounselorsViewController *)([navController viewControllers][0]);
        cVC.delegate = self;
        
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.tableViewRefreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.tableViewRefreshControl scrollViewDidEndDragging];
}

- (void)refreshTriggered:(id)sender {
    dispatch_queue_t serverDelaySimulationThread = dispatch_queue_create("com.xxx.serverDelay", nil);
    dispatch_async(serverDelaySimulationThread, ^{
        [NSThread sleepForTimeInterval:5.0];
        dispatch_async(dispatch_get_main_queue(), ^{
            //Your server communication code here
            LYRQuery *lyrQuery = [LYRQuery queryWithClass:[LYRConversation class]];
            lyrQuery.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.receivedAt" ascending:NO]];
            self.queryController = [layerClient queryControllerWithQuery:lyrQuery];
            self.queryController.delegate = self;
            
            NSError *error;
            BOOL success = [self.queryController execute:&error];
            if (success) {
               NSLog(@"Query fetched %tu conversation objects", [self.queryController numberOfObjectsInSection:0]);
                if(self.queryController.count > 0) {
                    [self.conversationsTableView reloadData];
                    [self.tableViewRefreshControl finishingLoading];
                }
            } else {
                NSLog(@"Query failed with error %@", error);
                [self.tableViewRefreshControl finishingLoading];
            }
        });
    });
}

#pragma mark collection view stuff

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [counselors count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"CounselorCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    CRCounselor *counselor = [counselors objectAtIndex:indexPath.item];
    
    UIImageView *avatarImageView = (UIImageView *)[cell viewWithTag: 100];
    avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2;
    avatarImageView.layer.borderWidth = 0;
    avatarImageView.layer.masksToBounds = YES;
    [avatarImageView sd_setImageWithURL:[NSURL URLWithString:counselor.avatarString] placeholderImage:[UIImage imageNamed:@"placeholderIcon.png"]];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
    nameLabel.text = [[counselor.name componentsSeparatedByString:@" "] firstObject];
    
    return cell;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
