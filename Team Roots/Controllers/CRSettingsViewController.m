//
//  CRSettingsViewController.m
//  
//
//  Created by Alex Yeh on 2/28/15.
//
//

#import "CRSettingsViewController.h"

NSUInteger const kUserSection = 0;
NSUInteger const kImportantSection = 1;
NSUInteger const kLogoutSection = 2;

@interface CRSettingsViewController ()

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
    
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIFont fontWithName:@"AvenirNext-Regular" size:26] forKey:NSFontAttributeName];
    [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
    CGFloat verticalOffset = 0;
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:verticalOffset forBarMetrics:UIBarMetricsDefault];

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
            headerLabel.text = @"Imporant Stuff";
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
            cell.textLabel.text = @"User";
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
#warning todo logout
            break;
        }
        default: {
            break;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
