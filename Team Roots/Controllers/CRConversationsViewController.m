//
//  CRConversationsViewController.m
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "CRConversationsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+Team_Roots.h"
#import "UIImage+Team_Roots.h"
#import "CRCounselor.h"

#define PUSH_CHAT_VC_SEGUE @"pushChatVC"
#define MODAL_COUNSELORS_VC_SEGUE @"ModalCounselorsVC"
#define MODAL_SETTINGS_VC_SEGUE @"modalSettings"

@interface CRConversationsViewController ()

@end

@implementation CRConversationsViewController {
    CRConversation *loadedConversation;
    LYRClient *layerClient;
    UILabel *messageLabel;
    NSMutableArray *counselors;
    CRCounselor *selectedCounselor;
}

- (void)viewDidLoad {
    [super viewDidLoad];


    counselors = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"counselorType"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for(int i = 0; i < objects.count; i++){
                CRCounselor *counselor = [[CRCounselor alloc] initWithID:[objects[i] objectForKey:@"userID"] avatarString:[objects[i] objectForKey:@"photoURL"] name:[objects[i] objectForKey:@"name"] bio:[objects[i] objectForKey:@"bio"]];
                [counselors addObject:counselor];
                [self.counselorsCollectionView reloadData];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    layerClient = [CRConversationManager layerClient];
    
    if(self.receivedConversationToLoad) {
        loadedConversation = self.receivedConversationToLoad;
        [self performSegueWithIdentifier:PUSH_CHAT_VC_SEGUE sender:self];
    }
    
    LYRQuery *lyrQuery = [LYRQuery queryWithClass:[LYRConversation class]];
    lyrQuery.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.receivedAt" ascending:NO]];
    self.queryController = [layerClient queryControllerWithQuery:lyrQuery];
    self.queryController.delegate = self;
    
    self.navigationController.navigationBar.translucent = NO;
    self.conversationsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(counselorsTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.counselorsCollectionView addGestureRecognizer:tapRecognizer];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableViewRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.conversationsTableView target:self refreshAction:@selector(refreshTriggered:) plist:@"refreshControl" color:[UIColor whiteColor] lineWidth:1.5 dropHeight:40 scale:1 horizontalRandomness:150 reverseLoadingAnimation:YES internalAnimationFactor:0.5];
    
    UIButton *settingsButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [settingsButton setFrame:CGRectMake(0.0f, 0.0f, 25.0f, 25.0f)];
    [settingsButton setImage:[UIImage tr_imageNamed:@"settings-icon" withTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchUpInside];
    settingsButton.layer.masksToBounds = YES;
    settingsButton.alpha = 1.0;
    UIBarButtonItem *settingsBarButton = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    self.navigationItem.rightBarButtonItem = settingsBarButton;
    
    messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, self.view.bounds.size.width - 90, 200)];
    messageLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 30);
    messageLabel.text = @"No conversations yet. Tap the faces above :)";
    messageLabel.textColor = [UIColor lightGrayColor];
    messageLabel.numberOfLines = 4;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:25];
    messageLabel.alpha = 0.6;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    

    
    if(self.queryController.count > 0)
        [messageLabel removeFromSuperview];
    
        NSError *error;
    
        BOOL success = [self.queryController execute:&error];
    if (success) {
        NSLog(@"Query fetched %tu conversation objects", [self.queryController numberOfObjectsInSection:0]);
        if(self.queryController.count == 0) {
         
            [self.view addSubview:messageLabel];
            
            self.conversationsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self.conversationsTableView reloadData];
        } else {
            [messageLabel removeFromSuperview];
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
   // [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)conversationChange:(NSNotification *)notification {
    
    NSDictionary *changeObject = (NSDictionary *)notification.object;
    LYRConversation *conversation = changeObject[@"object"];

}

- (void)messageChange:(NSNotification *)notification {
    NSDictionary *changeObject = (NSDictionary *)notification.object;
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back (1)" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
//    LYRMessage *message = changeObject[@"object"];
//    if(![message.sentByUserID isEqualToString:self.conversation.participant.userID] && ![message.sentByUserID isEqualToString:[CRAuthenticationManager sharedInstance].currentUser.userID]) {
//        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
//        self.navigationItem.backBarButtonItem = backButton;
//    }
}

- (void)counselorsTapped:(UITapGestureRecognizer*)sender {
    [self performSegueWithIdentifier:MODAL_COUNSELORS_VC_SEGUE sender:self];
   
}

- (void)showSettings:(id)sender {
    [self performSegueWithIdentifier:MODAL_SETTINGS_VC_SEGUE sender:self];
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
        cVC.selectedCounselor = selectedCounselor;
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
    if(self.queryController.count > 0)
        [messageLabel removeFromSuperview];
    else
        [self.view addSubview:messageLabel];

    switch (type) {
        case LYRQueryControllerChangeTypeInsert:
            [self.conversationsTableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case LYRQueryControllerChangeTypeUpdate: {
            NSLog(@"%@", object);
            LYRConversation *conversation = object;
            if(![[conversation.identifier absoluteString] isEqualToString:[loadedConversation.layerConversation.identifier absoluteString]]) {
                UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back (1)" style:UIBarButtonItemStyleDone target:nil action:nil];
                self.navigationItem.backBarButtonItem = back;
            }
            [self.conversationsTableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
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
                } else if(self.queryController.count == 0){
                    messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, self.view.bounds.size.width - 90, 200)];
                    messageLabel.center = CGPointMake(self.view.center.x, self.view.center.y - 30);
                    messageLabel.text = @"No conversations yet. Tap the faces above :)";
                    messageLabel.textColor = [UIColor lightGrayColor];
                    messageLabel.numberOfLines = 4;
                    messageLabel.textAlignment = NSTextAlignmentCenter;
                    messageLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:25];
                    messageLabel.alpha = 0.6;
                    [self.view addSubview:messageLabel];
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
    selectedCounselor = [counselors objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:MODAL_COUNSELORS_VC_SEGUE sender:self];
}

@end
