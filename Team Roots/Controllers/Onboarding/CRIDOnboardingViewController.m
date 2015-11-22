//
//  CRIDOnboardingViewController.m
//  Team Roots
//
//  Created by Spencer Yen on 11/22/15.
//  Copyright © 2015 Parameter Labs. All rights reserved.
//

#import "CRIDOnboardingViewController.h"
#import "CRAuthenticationManager.h"
#import "CRConversationManager.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface CRIDOnboardingViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *IDTextfield;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@property NSString *userID;

@end

@implementation CRIDOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.IDTextfield becomeFirstResponder];
    
    self.nextButton.enabled = NO;
    self.nextButton.alpha = 0.5f;
    self.nextButton.layer.cornerRadius = 5.f;
    
    [self.IDTextfield addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];

}

- (void)textFieldChanged:(UITextField *)textField
{
    self.userID = textField.text;
    
    if (textField.text.length > 0) {
        self.nextButton.enabled = YES;
        self.nextButton.alpha = 1.f;
    } else {
        self.nextButton.enabled = NO;
        self.nextButton.alpha = 0.5f;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)nextTapped:(id)sender {
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
    [[CRAuthenticationManager sharedInstance] authenticateUserID:self.userID completionBlock:^(BOOL authenticated) {
        if(authenticated){
            [[CRAuthenticationManager sharedInstance] authenticateLayerWithID:self.userID client:[CRConversationManager layerClient] completionBlock:^(NSString *authenticatedUserID, NSError *error) {
                if(!error) {
#warning avatar is fake
                    [CRAuthenticationManager sharedInstance].currentUser = [[CRUser alloc] initWithID:self.userID avatarString:@"https://spacelist.ca/assets/v2/placeholder-user.jpg" name:self.userID schoolID:self.schoolID];
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[CRAuthenticationManager sharedInstance].currentUser];
                    [defaults setObject:data forKey:CRCurrentUserKey];
                    [defaults synchronize];
                    
                    [self.navigationController performSegueWithIdentifier:@"PushFTCounselorVC" sender:self];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops, something went wrong with Layer authentication" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Looks like this isn't a valid ID." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
}

- (IBAction)backTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
