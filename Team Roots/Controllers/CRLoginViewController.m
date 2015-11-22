//
//  CRLoginViewController.m
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "CRLoginViewController.h"
#import "CRAuthenticationManager.h"

@interface CRLoginViewController ()

@end


@implementation CRLoginViewController {
    BOOL showingNotification;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkUserAuthenticationStatus];
}

- (void)checkUserAuthenticationStatus {
    [CRAuthenticationManager loadCurrentUser];
   
    if ([CRAuthenticationManager sharedInstance].currentUser) {
        [self presentConversationsViewControllerAnimated:NO];
    } else {
    
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navController = [segue destinationViewController];
    assert([([navController viewControllers][0]) isKindOfClass:[CRConversationsViewController class]]);
    CRConversationsViewController *conversationVC = (CRConversationsViewController *)([navController viewControllers][0]);
    if(self.receivedConversationToLoad) {
        conversationVC.receivedConversationToLoad = self.receivedConversationToLoad;
    }
}

- (void)presentConversationsViewControllerAnimated:(BOOL)animated {
    if(animated) {
        [self performSegueWithIdentifier:@"presentConversationsAnimated" sender:self];
    } else {
        [self performSegueWithIdentifier:@"presentConversationsNotAnimated" sender:self];
    }
}

- (void)notificationTappedWithConversation:(CRConversation *)conversation {
    NSLog(@"notificaiton tappeD: %@", conversation);
}

@end
