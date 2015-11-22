//
//  CRChatViewController.m
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "CRChatViewController.h"
#import "UIColor+Team_Roots.h"

static NSString *const MIMETypeTextPlain = @"text/plain";

@interface CRChatViewController ()

@property (strong, nonatomic) IBOutlet UIView *messagesContainer;

@end

@implementation CRChatViewController {
    BOOL isFullScreen;
    CGRect originalJSQFrame;
    BOOL showingNotification;
    UILabel *messageLabel;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"Team Roots";
    
    //full screen
//    isFullScreen = FALSE;
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeFullScreen:)];
//    tapGestureRecognizer.numberOfTapsRequired = 2;
//    [self.view addGestureRecognizer: tapGestureRecognizer];
//    originalJSQFrame = self.messagesContainer.frame;

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"messagesEmbed"]) {
        CRMessagesViewController *messagesVC = (CRMessagesViewController *)[segue destinationViewController];
        messagesVC.conversation = self.conversation;
    } else if ([segue.identifier isEqualToString: @"profileEmbed"]) {
        CRChatProfileViewController *profileVC = (CRChatProfileViewController *)[segue destinationViewController];
        profileVC.conversation = self.conversation;
    }
}

//- (void)makeFullScreen: (UITapGestureRecognizer *)recognizer
//{
//    if (!isFullScreen) {
//        [UIView animateWithDuration: 0.3f animations: ^{
//            self.messagesContainer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//        }];
//        [UIView animateWithDuration: 0.5f animations:^(void) {
//            UIBarButtonItem *profileBarButton = [[UIBarButtonItem alloc] initWithCustomView: profileButton];
//            self.navigationItem.rightBarButtonItem = profileBarButton;
//            profileButton.alpha = 1.0;
//        }];
//        isFullScreen = !isFullScreen;
//    } else {
//        [self showProfile];
//    }
//}

@end
