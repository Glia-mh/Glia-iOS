//
//  CRChatProfileViewController.m
//  Common Roots
//
//  Created by Spencer Yen on 6/12/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "CRChatProfileViewController.h"
#import "CRCounselor.h"
@interface CRChatProfileViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *profileBioTextview;

- (IBAction)callTapped:(id)sender;

@end

@implementation CRChatProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CRCounselor *counselor = (CRCounselor *)self.conversation.participant;

    self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.borderWidth = 0;
    self.profileImageView.layer.masksToBounds = YES;
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:self.conversation.participant.avatarString] placeholderImage:[UIImage imageNamed:@"placeholderIcon.png"]];
    
    self.profileNameLabel.text = counselor.name;
    self.profileBioTextview.text = counselor.counselorBio;
}

- (IBAction)callTapped:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Calling will be availible soon!" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
}

@end
