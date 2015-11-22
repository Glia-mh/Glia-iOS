//
//  CRSchoolOnboardingViewController.m
//  Team Roots
//
//  Created by Spencer Yen on 11/21/15.
//  Copyright © 2015 Parameter Labs. All rights reserved.
//

#import "CRSchoolOnboardingViewController.h"
#import "UIColor+Team_Roots.h"
#import "CRIDOnboardingViewController.h"

@interface CRSchoolOnboardingViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *schoolsTableView;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property NSIndexPath *checkedIndexPath;
@property NSArray *schools;

@end

@implementation CRSchoolOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nextButton.layer.cornerRadius = 5.f;
    self.schools = @[@"Saratoga High School", @"University of Southern California"];
    self.checkedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    CRIDOnboardingViewController *idOnboardingVC = [segue destinationViewController];
    idOnboardingVC.schoolID = [self.schools objectAtIndex:self.checkedIndexPath.row];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.schools.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if(self.checkedIndexPath)
    {
        UITableViewCell* uncheckCell = [tableView
                                        cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.checkedIndexPath = indexPath;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *schoolCellIdentifier = @"SchoolCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:schoolCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:schoolCellIdentifier];
    }

    cell.tintColor = [UIColor teamRootsGreen];

    UILabel *schoolLabel = (UILabel*) [cell viewWithTag:100];
    schoolLabel.text = [self.schools objectAtIndex:indexPath.row];
    schoolLabel.adjustsFontSizeToFitWidth = YES;
    
    if([self.checkedIndexPath isEqual:indexPath])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    
    return view;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (IBAction)backTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
