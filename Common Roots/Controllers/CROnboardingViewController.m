//
//  CROnboardingViewController.m
//  Common Roots
//
//  Created by Spencer Yen on 6/11/15.
//  Copyright © 2015 Parameter Labs. All rights reserved.
//

#import "CROnboardingViewController.h"
#import <Onboard/OnboardingContentViewController.h>
#import <Onboard/OnboardingViewController.h>

@interface CROnboardingViewController ()

@end

@implementation CROnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];


}

- (void)viewDidAppear:(BOOL)animated {
    OnboardingContentViewController *firstPage = [OnboardingContentViewController contentWithTitle:@"Page Title" body:@"Page body goes here." image:[UIImage imageNamed:@"icon"] buttonText:@"Text For Button" action:^{
        // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
    }];
    
    OnboardingContentViewController *secondPage = [OnboardingContentViewController contentWithTitle:@"Page Title" body:@"Page body goes here." image:[UIImage imageNamed:@"icon"] buttonText:@"Text For Button" action:^{
        // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
    }];
    
    OnboardingContentViewController *thirdPage = [OnboardingContentViewController contentWithTitle:@"Page Title" body:@"Page body goes here." image:[UIImage imageNamed:@"icon"] buttonText:@"Text For Button" action:^{
        // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
    }];
    
    OnboardingViewController *onboardingVC = [OnboardingViewController onboardWithBackgroundImage:[UIImage imageNamed:@"background"] contents:@[firstPage, secondPage, thirdPage]];
    [self presentViewController:onboardingVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
