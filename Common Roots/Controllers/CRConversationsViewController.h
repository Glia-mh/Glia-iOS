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
#import <BlurImageProcessor/ALDBlurImageProcessor.h>

@interface CRConversationsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) CRConversation *receivedConversationToLoad;

@end
