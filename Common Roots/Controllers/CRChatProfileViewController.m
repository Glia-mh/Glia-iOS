//
//  CRChatProfileViewController.m
//  Common Roots
//
//  Created by Spencer Yen on 6/12/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "CRChatProfileViewController.h"

@interface CRChatProfileViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *profileBioTextview;

@end

@implementation CRChatProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", self.conversation.participant.avatarString);
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.borderWidth = 0;
    self.profileImageView.layer.masksToBounds = YES;
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:self.conversation.participant.avatarString] placeholderImage:[UIImage imageNamed:@"placeholderIcon.png"]];
    
    self.profileNameLabel.text = self.conversation.participant.name;
   // self.profileBioTextview.text = self.conversation.participant.counselorBio;
    
    
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
