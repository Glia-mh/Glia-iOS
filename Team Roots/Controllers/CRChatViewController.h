//
//  CRChatViewController.h
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessagesViewController/JSQMessages.h"
#import "CRCounselor.h"
#import "CRUser.h"
#import "CRConversation.h"
#import "CRConversationManager.h"
#import <BlurImageProcessor/ALDBlurImageProcessor.h>
#import <LayerKit/LayerKit.h>

#import <SDWebImage/UIImageView+WebCache.h>
#import "CRLocalNotificationView.h"

#import "CRChatProfileViewController.h"
#import "CRMessagesViewController.h"

@interface CRChatViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) CRConversation *conversation;

@property (strong, nonatomic) LYRClient *layerClient;

@end
