//
//  UIImage+Team_Roots.h
//  Team Roots
//
//  Created by Spencer Yen on 11/18/15.
//  Copyright © 2015 Parameter Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Team_Roots)

#pragma mark Image Manipulation

/**
 *  Scale a given image to a specified size.
 *
 *  @param image      Image to scale.
 *  @param targetSize Desired target size.
 *
 *  @return New UIImage instance containing the scaled image.
 *
 *  @since 1.0
 */
+ (instancetype)tr_scaleImage:(UIImage *)image
                       toSize:(CGSize)targetSize;

/**
 *  Tint a given image with a specified color.
 *
 *  @param name      Image to tint.
 *  @param tintColor Tint color.
 *
 *  @return New UIImage instance containing the tinited image.
 *
 *  @since 1.0
 */
+ (instancetype)tr_imageNamed:(NSString *)name
                withTintColor:(UIColor *)tintColor;

+ (instancetype)tr_imageWithInitials:(NSString *)initials size:(CGSize)size;

+ (instancetype)tr_screenshotOfView:(UIView *)view
                           cropRect:(CGRect)cropRect;

+ (instancetype)tr_screenshotOfView:(UIView *)view
                           cropRect:(CGRect)cropRect
                     normalizedSize:(CGSize)normalizedSize;

/**
 *  Tint this image with a given color.
 *
 *  @param tintColor Tint color.
 *
 *  @return New UIImage instance containing the tinted image.
 *
 *  @since 1.0
 */


- (UIImage *)tr_blendedOnImage:(UIImage *)image
                        onSize:(CGSize)size
                    withOffset:(CGPoint)offset
                 withTintColor:(UIColor *)tintColor;

+ (UIImage *)tr_overlayImage:(UIImage *)foregroundImage onImage:(UIImage *)backgroundImage;

+ (UIImage *)tr_overlayImage:(UIImage *)foregroundImage onImage:(UIImage *)backgroundImage atPoint:(CGPoint)point;

+ (UIImage *)tr_attachImage:(UIImage *)bottomImage belowImage:(UIImage *)topImage;

+ (UIImage *)tr_roundedRectImageFromImage:(UIImage *)image
                                     size:(CGSize)imageSize
                         withCornerRadius:(float)cornerRadius;
+ (UIImage *)tr_imageWithColor:(UIColor *)color rect:(CGRect)rect;


@end
