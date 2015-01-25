//
//  CRCounselorView.m
//  Common Roots
//
//  Created by Spencer Yen on 1/17/15.
//  Copyright (c) 2015 Parameter Labs. All rights reserved.
//

#import "CRCounselorView.h"
#import <Parse/Parse.h>
#import "SDWebImage/UIImageView+WebCache.h"

#define CR_COUNSELOR_CELL_IDENTIFIER @"CR_COUNSELOR_CELL_IDENTIFIER"

@implementation CRCounselorView {
    NSMutableArray *counselorImageURLs;
}

- (id)init {
    if (self = [super init]){
        self.backgroundColor = [UIColor clearColor];
        
        counselorImageURLs = [[NSMutableArray alloc] init];
        PFQuery *query = [PFQuery queryWithClassName:@"Counselors"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for(int i = 0; i < objects.count; i++){
                    [counselorImageURLs addObject:[objects[i] objectForKey:@"Image_URL"]];
                    if(i == objects.count - 1) {
                        [self reloadData];
                    }
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [counselorImageURLs count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"CounselorCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *avatarImageView = (UIImageView *)[cell viewWithTag: 100];
    [avatarImageView sd_setImageWithURL:[NSURL URLWithString:[counselorImageURLs objectAtIndex:indexPath.item]] placeholderImage:[UIImage imageNamed:@"placeholderIcon.png"]];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
