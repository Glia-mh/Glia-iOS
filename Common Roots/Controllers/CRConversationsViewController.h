//
//  CRConversationsViewController.h
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "CRChatViewController.h"
#import "CRConversationManager.h"
#import "CRConversation.h"
#import "CRCounselorView.h"
#import <BlurImageProcessor/ALDBlurImageProcessor.h>

@interface CRConversationsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, LYRQueryControllerDelegate>

@property (strong, nonatomic) CRConversation *receivedConversationToLoad;
@property (strong, nonatomic) LYRQueryController *queryController;

@property (weak, nonatomic) IBOutlet UITableView *conversationsTableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIView *refreshColorView;
@property (nonatomic, strong) UIImageView *compass_background;
@property (nonatomic, strong) UIImageView *compass_spinner;
@property (assign) BOOL isRefreshIconsOverlap;
@property (assign) BOOL isRefreshAnimating;

@end
