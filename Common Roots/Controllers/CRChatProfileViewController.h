//
//  CRChatProfileViewController.h
//  Common Roots
//
//  Created by Spencer Yen on 6/12/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRConversation.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface CRChatProfileViewController : UIViewController

@property (strong, nonatomic) CRConversation *conversation;

@end
