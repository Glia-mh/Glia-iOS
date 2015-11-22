//
//  CRStartOnboardingViewController.m
//  Team Roots
//
//  Created by Spencer Yen on 11/21/15.
//  Copyright © 2015 Parameter Labs. All rights reserved.
//

#import "CRStartOnboardingViewController.h"

@interface CRStartOnboardingViewController ()

@property (strong, nonatomic) IBOutlet UIButton *getStartedButton;

@end

@implementation CRStartOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;

    self.getStartedButton.layer.cornerRadius = 5.f;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (IBAction)getStartedTapped:(id)sender {
}

@end
