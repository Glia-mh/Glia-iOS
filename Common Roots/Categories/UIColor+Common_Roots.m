//
//  UIColor+Anon.m
//  Anon
//
//  Created by Spencer Yen on 11/10/14.
//  Copyright (c) 2014 Spencer Yen. All rights reserved.
//

#import "UIColor+Common_Roots.h"

@implementation UIColor (Common_Roots)

+ (UIColor*)unreadBlue {
    UIColor *blue = [UIColor colorWithRed:65.0f/255.0f green:131.0f/255.0f blue:215.0f/255.0f alpha:1.0f];
    return blue;
}

+ (UIColor*)commonRootsGreen {
   return [UIColor colorWithRed:70.0/255.0f green:190.0/255.0f blue:76.0/255.0f alpha:1.0f];
}

@end