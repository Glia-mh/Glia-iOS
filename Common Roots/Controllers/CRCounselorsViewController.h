//
//  CRCounselorsViewController.h
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse-iOS/Parse.h>
#import "CRCounselorView.h"
@interface CRCounselorsViewController : PFQueryTableViewController

@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionToTypeMap;
@property (nonatomic, retain) NSMutableDictionary *companies;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end