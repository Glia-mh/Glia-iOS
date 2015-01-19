//
//  CRLoginViewController.m
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "CRLoginViewController.h"

@interface CRLoginViewController ()

@end

@implementation CRLoginViewController {
    LYRClient *client;
    NSString *userID;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginButton.alpha = 0.0f;
    self.studentIDTextField.alpha = 0.0f;
    
    [self checkUserAuthenticationStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkUserAuthenticationStatus {
    client = [CRConversationManager layerClient];
    
    //If the user is already logged in/linked, skip login
    if ([[CRAuthenticationManager sharedInstance] currentUser].userID) {
        [self presentConversationsViewControllerAnimated:NO];        
    } else {
        [UIView animateWithDuration: 0.5f animations: ^{
            self.loginButton.alpha = 1.0f;
            self.studentIDTextField.alpha = 1.0f;
        }completion:nil];
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
    userID = @"1234123";
    [[CRAuthenticationManager sharedInstance] authenticateUserID:userID completionBlock:^(BOOL authenticated) {
        if(authenticated){
            [[CRAuthenticationManager sharedInstance] authenticateLayerWithID:userID client:client completionBlock:^(NSString *authenticatedUserID, NSError *error) {
                if(!error) {
                    NSString *userIDMD5Hash = [[CRAuthenticationManager sharedInstance] md5HexDigest:userID];
                    NSString *avatarString = [NSString stringWithFormat:@"http://vanillicon.com/%@_200.png", userIDMD5Hash];
                    
                    [CRAuthenticationManager sharedInstance].currentUser = [[CRUser alloc] initWithID:userID avatarString:avatarString name:userID];
                    [self performSegueWithIdentifier:@"presentConversationsAnimated" sender:self];
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
}

@end
