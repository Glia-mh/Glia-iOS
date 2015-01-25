//
//  CRLoginViewController.m
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#define PADDING 10

#import "CRLoginViewController.h"

@interface CRLoginViewController ()

@end

@implementation CRLoginViewController {
    LYRClient *client;
    NSString *userID;
    BOOL showingNotification;
    BOOL showingDisclaimer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.studentIDTextField.delegate = self;
    showingDisclaimer = FALSE;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkUserAuthenticationStatus];
}

- (void)checkUserAuthenticationStatus {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"currentUser"];
    [CRAuthenticationManager sharedInstance].currentUser = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    if ([CRAuthenticationManager sharedInstance].currentUser != nil) {
//        CRUser *counselor = [[CRUser alloc] initWithID:@"10312" avatarString:@"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xfa1/v/t1.0-1/c0.4.200.200/p200x200/10438898_820232517987524_446322531645685986_n.jpg?oh=1f1795d47fa2a0cb5156498a31129f48&oe=5563894A&__gda__=1431928635_8865d99c3824cda82704e9cb08854376" name:@"Spencer"];
//        [[CRConversationManager sharedInstance] newConversationWithCounselor:counselor client:client completionBlock:^(CRConversation *conversation, NSError *error) {
//            CRLocalNotificationView *notificationView = [[CRLocalNotificationView alloc] initWithConversation:conversation text:@"This is a test to see if in app notifications work" width: self.view.frame.size.width];
//            notificationView.delegate = self;
//            [self.view addSubview:notificationView];
//            showingNotification = YES;
//            [self setNeedsStatusBarAppearanceUpdate];
//            [notificationView showWithDuration:5.0 withCompletion:^(BOOL done) {
//                showingNotification = NO;
//                [self setNeedsStatusBarAppearanceUpdate];
//            }];
//        }];
        
        [self presentConversationsViewControllerAnimated:NO];
    } else {
        self.loginButton.alpha = 0.0f;
        self.studentIDTextField.alpha = 0.0f;
        self.disclaimerTextView.alpha = 0.0f;
        
        self.titleLabel.center = CGPointMake(self.view.center.x, PADDING + self.titleLabel.frame.size.height);
        self.sloganLabel.center = CGPointMake(self.view.center.x, PADDING + self.titleLabel.frame.size.height + self.sloganLabel.frame.size.height/2);
        
        self.loginButton.frame = CGRectMake(0, self.view.frame.size.height - self.loginButton.frame.size.height - PADDING, self.loginButton.frame.size.width, self.loginButton.frame.size.height);
        self.loginButton.center = CGPointMake(self.view.center.x, self.loginButton.center.y);
        self.studentIDTextField.frame = self.loginButton.frame;
        
        self.disclaimerTextView.frame = CGRectMake(0, self.sloganLabel.frame.origin.y + self.sloganLabel.frame.size.height + PADDING, self.loginButton.frame.size.width, self.loginButton.frame.origin.y - PADDING - (self.sloganLabel.frame.origin.y + self.sloganLabel.frame.size.height + PADDING));
        self.disclaimerTextView.center = CGPointMake(self.view.center.x, self.disclaimerTextView.center.y);
        
        [UIView animateWithDuration: 1.5f animations: ^{
            self.studentIDTextField.alpha = 1.0f;
            self.loginButton.alpha = 1.0f;
            self.studentIDTextField.alpha = 1.0f;
        }completion:nil];
        
        client = [CRConversationManager layerClient];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
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
//    RTSpinKitView *spinner = [[RTSpinKitView alloc] initWithStyle: RTSpinKitViewStyleCircleFlip color:[UIColor whiteColor]];
//    spinner.center = CGPointMake(self.view.center.x, self.view.center.y - self.navigationController.navigationBar.frame.size.height);
//    [spinner startAnimating];
//    [self.view addSubview:spinner];
    
    userID = self.studentIDTextField.text;

    if (userID.length != 0) {
        if(showingDisclaimer) {
            NSLog(@"q3rt3rtq34tq34tq34tq34tq34tq34tq34tq34t");
            [[CRAuthenticationManager sharedInstance] authenticateUserID:userID completionBlock:^(BOOL authenticated) {
                if(authenticated){
                    [[CRAuthenticationManager sharedInstance] authenticateLayerWithID:userID client:client completionBlock:^(NSString *authenticatedUserID, NSError *error) {
                        if(!error) {
                            [self.studentIDTextField resignFirstResponder];
                            
                            NSString *userIDMD5Hash = [[CRAuthenticationManager sharedInstance] md5String:userID];
                            NSString *avatarString = [NSString stringWithFormat:@"http://vanillicon.com/%@_200.png", userIDMD5Hash];
                        
                            [CRAuthenticationManager sharedInstance].currentUser = [[CRUser alloc] initWithID:userID avatarString:avatarString name:userID];
                        
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[CRAuthenticationManager sharedInstance].currentUser];
                            [defaults setObject:data forKey:@"currentUser"];
                            [defaults synchronize];
                        
                        
                            [self presentConversationsViewControllerAnimated:YES];
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
        } else {
            [UIView animateWithDuration: 0.5 animations: ^{
                self.studentIDTextField.alpha = 0.0f;
                self.disclaimerTextView.alpha = 1.0f;
                self.loginButton.frame = CGRectMake(self.loginButton.frame.origin.x, self.view.frame.size.height - self.loginButton.frame.size.height - PADDING, self.loginButton.frame.size.width, self.loginButton.frame.size.height);
                [self.loginButton setTitle:@"I Agree" forState:UIControlStateNormal];
            }];
            [self.studentIDTextField resignFirstResponder];
            showingDisclaimer = TRUE;
        }
    } else {
        NSLog(@"wefewfwefwe");
        [UIView animateWithDuration: 0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations: ^{
            self.loginButton.frame = CGRectMake(self.loginButton.frame.origin.x, self.sloganLabel.frame.origin.y + 2*(self.loginButton.frame.size.height) + 2*PADDING, self.loginButton.frame.size.width, self.loginButton.frame.size.height);
            if(self.studentIDTextField.frame.origin.y > 200)
                self.studentIDTextField.frame = self.loginButton.frame;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration: 0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations: ^{
                self.studentIDTextField.frame = CGRectMake(self.studentIDTextField.frame.origin.x, self.sloganLabel.frame.origin.y + self.studentIDTextField.frame.size.height + PADDING, self.loginButton.frame.size.width, self.studentIDTextField.frame.size.height);
            } completion:nil];
        }];
    }
}

- (void)notificationTappedWithConversation:(CRConversation *)conversation {
    NSLog(@"notificaiton tappeD: %@", conversation);
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    if(!showingNotification) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

@end
