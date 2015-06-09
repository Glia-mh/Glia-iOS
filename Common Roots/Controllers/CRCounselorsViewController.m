//
//  CRCounselorsViewController.m
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "CRCounselorsViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "CRConversationManager.h"
#import "UIColor+Common_Roots.h"

#define PARSE_COUNSELORS_CLASS_NAME @"Counselors"

@interface CRCounselorsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CRCounselorsViewController {
    int numStudentCounselors;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];

    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIFont fontWithName:@"AvenirNext-Regular" size:18] forKey:NSFontAttributeName];
    [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
    CGFloat verticalOffset = -1;
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:verticalOffset forBarMetrics:UIBarMetricsDefault];

    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.estimatedRowHeight = 80.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Counselors"];
    [query orderByAscending:@"isAvailible"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for(int i = 0; i < objects.count; i++){
                [objects[i] objectForKey:@"Name"];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadObjects];
}

- (void)viewDidAppear:(BOOL)animated {

}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        self.parseClassName = PARSE_COUNSELORS_CLASS_NAME;
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 150;
        self.sections = [NSMutableDictionary dictionary];
        self.sectionToTypeMap = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:PARSE_COUNSELORS_CLASS_NAME];
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    // Order by type
    [query orderByDescending:@"isAvailible"];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    return query;
}

- (NSString *)companyForSection:(NSInteger)section {
    return [self.sectionToTypeMap objectForKey:[NSNumber numberWithInt:(int)section]];
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
    
    [self.sections removeAllObjects];
    [self.sectionToTypeMap removeAllObjects];
    
    NSInteger section = 0;
    NSInteger rowIndex = 0;
    int studentCount = 0;
    for (PFObject *object in self.objects) {
        NSString *counselorType = [object objectForKey:@"counselorType"];
        NSMutableArray *objectsInSection = [self.sections objectForKey:counselorType];
        if([counselorType intValue] == 0) {
            studentCount++;
        }
        if (!objectsInSection) {
            objectsInSection = [NSMutableArray array];
            
            // this is the first time we see this company - increment the section index
            [self.sectionToTypeMap setObject:counselorType forKey:[NSNumber numberWithInt:(int)section++]];
        }
        [objectsInSection addObject:[NSNumber numberWithInt:(int)rowIndex++]];
        [self.sections setObject:objectsInSection forKey:counselorType];
    }
    numStudentCounselors = studentCount;
    [self.tableView reloadData];
}


- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSString *company = [self companyForSection:indexPath.section];
    
    NSArray *rowIndecesInSection = [self.sections objectForKey:company];
    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row];
    return [self.objects objectAtIndex:[rowIndex intValue]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *company = [self companyForSection:section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:company];
    return rowIndecesInSection.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *company = [self companyForSection:section];
    return company;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    [view setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.7]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:15]];
    [label setTextColor:[UIColor whiteColor]];
    NSString *company = [self companyForSection:section];
    if([company isEqualToString:@"0"]) {
        [label setText:@"Student Counselors"];
    } else {
        [label setText:@"CASSY Counselors"];
    }
    [view addSubview:label];
    return view;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    PFObject *selectedObject = [self objectAtIndexPath:indexPath];
    
    CRUser *user = [[CRUser alloc] initWithID:[selectedObject objectForKey:@"userID"] avatarString:[selectedObject objectForKey:@"Photo_URL"] name:[selectedObject objectForKey:@"Name"]];
    [[CRConversationManager sharedInstance] newConversationWithCounselor:user client:[CRConversationManager layerClient] completionBlock:^(CRConversation *conversation, NSError *error) {
        if([_delegate respondsToSelector:@selector(counselorsViewControllerDismissedWithConversation:)]) {
            [_delegate counselorsViewControllerDismissedWithConversation:conversation];
            NSLog(@"conversation passed");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *conciergeCellIdentifier = @"CounselorCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:conciergeCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:conciergeCellIdentifier];
    }
    
    UILabel *nameLabel = (UILabel*) [cell viewWithTag:101];
    nameLabel.text = [object objectForKey:@"Name"];
    
    UILabel *bioLabel = (UILabel*) [cell viewWithTag:102];
    bioLabel.numberOfLines = 0;
    NSString *bioString = [object objectForKey:@"Bio"];
    bioLabel.text = bioString;

    UIImageView *avatarImageView = (UIImageView*) [cell viewWithTag:100];
    avatarImageView.clipsToBounds = YES;
    avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2;
    [avatarImageView sd_setImageWithURL:[NSURL URLWithString:[object objectForKey:@"Photo_URL"]] placeholderImage:[UIImage imageNamed:@"placeholderIcon.png"]];
    
    UILabel *onlineLabel = (UILabel *)[cell viewWithTag:103];
    if([[object objectForKey:@"isAvailible"] isEqualToString:@"NO"]){
        onlineLabel.text = @"● Offline";
        onlineLabel.textColor = [UIColor redColor];
//temp removed cause weird bugs
//        nameLabel.alpha = 0.3;
//        bioLabel.alpha = 0.3;
//        avatarImageView.alpha = 0.3;
    } else {
        onlineLabel.text = @"● Online";
        onlineLabel.textColor = [UIColor commonRootsGreen];
    }
    
    return cell;
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end