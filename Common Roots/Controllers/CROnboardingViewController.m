//
//  CROnboardingViewController.m
//  Common Roots
//
//  Created by Spencer Yen on 6/11/15.
//  Copyright © 2015 Parameter Labs. All rights reserved.
//

#import "CROnboardingViewController.h"
#import "OnboardingContentViewController.h"
#import "OnboardingViewController.h"

@interface CROnboardingViewController ()

@end

@implementation CROnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];


}

- (void)viewDidAppear:(BOOL)animated {
    OnboardingContentViewController *firstPage = [OnboardingContentViewController contentWithTitle:@"Common Roots" body:@"Anonymous counseling." image:[UIImage imageNamed:@"icon"] buttonText:@"Get Started" action:^{
        // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
    }];
    firstPage.titleFontName = @"AvenirNext-Thin";
    
    OnboardingContentViewController *secondPage = [OnboardingContentViewController contentWithTitle:@"Page Title" body:@"Page body goes here." image:[UIImage imageNamed:@"icon"] buttonText:@"Text For Button" action:^{
        // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
    }];
    
    OnboardingContentViewController *thirdPage = [OnboardingContentViewController contentWithTitle:@"Page Title" body:@"Page body goes here." image:[UIImage imageNamed:@"icon"] buttonText:@"Text For Button" action:^{
        // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
    }];
    
    OnboardingViewController *onboardingVC = [OnboardingViewController onboardWithBackgroundImage:[UIImage imageNamed:@"greenBackground.png"] contents:@[firstPage, secondPage, thirdPage]];
    onboardingVC.shouldMaskBackground = NO;
    onboardingVC.fontName = @"AvenirNext-Regular";
    onboardingVC.titleFontSize = 28;
    onboardingVC.bodyFontSize = 22;
    onboardingVC.topPadding = 20;
    onboardingVC.underIconPadding = 10;
    onboardingVC.underTitlePadding = 15;
    onboardingVC.bottomPadding = -100;
    onboardingVC.underPageControlPadding = 80;
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

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}


@end
