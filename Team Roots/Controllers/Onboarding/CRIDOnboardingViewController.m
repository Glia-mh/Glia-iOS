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

@property (strong, nonatomic) IBOutlet UILabel *bodyLabel;
@property (strong, nonatomic) IBOutlet UITextField *IDTextfield;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@property NSString *userID;

@end

@implementation CRIDOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bodyLabel.text = [NSString stringWithFormat:@"Awesome! To verify you are a student at %@, enter your ID number.", [[CRAuthenticationManager sharedInstance] schoolNameForID:self.schoolID]];
    self.bodyLabel.adjustsFontSizeToFitWidth = YES;
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

    
    NSLog(@"This is the authentication sharedInstance: %@", [CRAuthenticationManager sharedInstance]);
    [[CRAuthenticationManager sharedInstance] authenticateUserID:self.userID completionBlock:^(BOOL authenticated) {
        if(authenticated){
            [SVProgressHUD show];

            [[CRAuthenticationManager sharedInstance] authenticateLayerWithID:self.userID client:[CRConversationManager layerClient] completionBlock:^(NSString *authenticatedUserID, NSError *error) {
                NSLog(error.description);
                if(!error) {
#warning avatar is fake
                    [CRAuthenticationManager sharedInstance].currentUser = [[CRUser alloc] initWithID:self.userID avatarString:@"https://spacelist.ca/assets/v2/placeholder-user.jpg" name:self.userID schoolID:self.schoolID schoolName:[[CRAuthenticationManager sharedInstance] schoolNameForID:self.schoolID]];
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[CRAuthenticationManager sharedInstance].currentUser];
                    [defaults setObject:data forKey:CRCurrentUserKey];
                    [defaults synchronize];
                    
                    [SVProgressHUD dismiss];

                    [self performSegueWithIdentifier:@"PushFTCounselorVC" sender:self];
                } else {
                    [SVProgressHUD dismiss];

                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops, something went wrong with Layer authentication" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }];
        } else {

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Looks like this isn't a valid ID." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}



- (IBAction)backTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
