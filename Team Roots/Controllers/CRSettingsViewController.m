//
//  CRSettingsViewController.m
//  
//
//  Created by Alex Yeh on 2/28/15.
//
//

#import "CRSettingsViewController.h"
#import "CRAuthenticationManager.h"
#import "CRConversationManager.h"

NSUInteger const kUserSection = 0;
NSUInteger const kImportantSection = 1;
NSUInteger const kLogoutSection = 2;

@interface CRSettingsViewController () <UIAlertViewDelegate>

@end

@implementation CRSettingsViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    self.title = @"Settings";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kUserSection:
            return 1;
        case kImportantSection:
            return 2;
        case kLogoutSection:
            return 1;
        default:
            return 0;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 48;
    
    return 38;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, tableView.frame.size.width, 18)];
    [headerLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:19]];
    [headerLabel setTextColor:[UIColor darkGrayColor]];
    switch (section) {
        case kUserSection:
            headerLabel.frame = CGRectMake(10, 17, tableView.frame.size.width, 18);
            headerLabel.text = @"Your Stuff";
            break;
        case kImportantSection:
            headerLabel.text = @"Important Stuff";
            break;
        default:
            break;
    }

    [headerView addSubview:headerLabel];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    switch (indexPath.section) {
        case kUserSection: {
            NSString *school = [NSString stringWithFormat:@"Signed in at %@",[CRAuthenticationManager schoolName]];
            cell.textLabel.text = school;
            cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:17];
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case kImportantSection: {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Terms and Conditions";
                    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:17];
                    cell.textLabel.textColor = [UIColor darkGrayColor];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 1:
                    cell.textLabel.text = @"Privacy Policy";
                    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:17];
                    cell.textLabel.textColor = [UIColor darkGrayColor];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                default:
                    break;
            }
            break;
        }
        case kLogoutSection: {
            cell.textLabel.text = @"Sign Out";
            cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:17];
            cell.textLabel.textColor = [UIColor redColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            break;
        }
        default: {
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kUserSection: {
            break;
        }
        case kLogoutSection: {
            [[CRAuthenticationManager sharedInstance] logoutUserWithClient:[CRConversationManager layerClient] completion:^(NSError *error) {
                if(error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops, something went wrong with logging out" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];

                } else {
                    NSLog(@"Logged out!");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"To finish signing out, we have to force close the app." message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    alert.tag = 100;
                    [alert show];
                }
            }];
            break;
        }
        default: {
            break;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
#warning temp force quit, implement later
    if(alertView.tag == 100) {
        exit(0);
    }
}

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
