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

static const CGFloat kPadding = 17.f;

@implementation CRLoginViewController {
    NSString *userID;
    BOOL showingNotification;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.studentIDTextField.delegate = self;
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

- (IBAction)loginTapped:(id)sender {
    
    userID = self.studentIDTextField.text;

    if (userID.length != 0) {
            [[CRAuthenticationManager sharedInstance] authenticateUserID:userID completionBlock:^(BOOL authenticated) {
                if(authenticated){
                    [[CRAuthenticationManager sharedInstance] authenticateLayerWithID:userID client:[CRConversationManager layerClient] completionBlock:^(NSString *authenticatedUserID, NSError *error) {
                        if(!error) {
                            [self.studentIDTextField resignFirstResponder];
#warning avatar is fake
                            [CRAuthenticationManager sharedInstance].currentUser = [[CRUser alloc] initWithID:userID avatarString:@"https://spacelist.ca/assets/v2/placeholder-user.jpg" name:userID bio:@""];
                            
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[CRAuthenticationManager sharedInstance].currentUser];
                            [defaults setObject:data forKey:CRCurrentUserKey];
                            [defaults synchronize];
                        } else {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops, layer" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        }
                    }];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Invalid id!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }];
             
            [UIView animateWithDuration: 0.5 animations: ^{
                self.studentIDTextField.alpha = 0.0f;
                self.disclaimerTextView.alpha = 1.0f;
                self.loginButton.frame = CGRectMake(self.loginButton.frame.origin.x, self.view.frame.size.height - self.loginButton.frame.size.height - kPadding, self.loginButton.frame.size.width, self.loginButton.frame.size.height);
                [self.loginButton setTitle:@"I Agree" forState:UIControlStateNormal];
            }];
            [self.studentIDTextField resignFirstResponder];
        }
}

- (void)notificationTappedWithConversation:(CRConversation *)conversation {
    NSLog(@"notificaiton tappeD: %@", conversation);
}

@end
