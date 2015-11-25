//
//  CRFTCounselorViewController.h
//  Team Roots
//
//  Created by Spencer Yen on 11/22/15.
//  Copyright © 2015 Parameter Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "CRConversation.h"
#import "CRCounselor.h"

@interface CRFTCounselorViewController : PFQueryTableViewController

@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionToTypeMap;
@property (nonatomic, retain) NSMutableDictionary *companies;

@property (nonatomic, retain) CRCounselor *selectedCounselor;

@end

