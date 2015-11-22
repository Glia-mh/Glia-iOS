//
//  UIColor+Team_Roots.m
//  Team Roots
//
//  Created by Spencer Yen on 11/18/15.
//  Copyright © 2015 Parameter Labs. All rights reserved.
//

#import "UIColor+Team_Roots.h"

@implementation UIColor (Team_Roots)

+ (UIColor*)unreadBlue {
    UIColor *blue = [UIColor colorWithRed:65.0f/255.0f green:131.0f/255.0f blue:215.0f/255.0f alpha:1.0f];
    return blue;
}

+ (UIColor*)teamRootsGreen {
    return [UIColor colorWithRed:135.0/255.0f green:211.0/255.0f blue:103.0/255.0f alpha:1.0f];
}

@end
