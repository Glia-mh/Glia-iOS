//
//  UIImage+Team_Roots.m
//  Team Roots
//
//  Created by Spencer Yen on 11/18/15.
//  Copyright © 2015 Parameter Labs. All rights reserved.
//

#import "UIImage+Team_Roots.h"

@implementation UIImage (Team_Roots)

#pragma mark Image Manipulation

NSString *tr_NSStringFromUIColor(UIColor *color)
{
    if (!color) {
        return nil;
    }
    
    const CGFloat *c = CGColorGetComponents(color.CGColor);
    
    if (CGColorGetNumberOfComponents(color.CGColor) == 2) {
        return [NSString stringWithFormat:@"{%f, %f}", c[0], c[1]];
    } else {
        return [NSString stringWithFormat:@"{%f, %f, %f, %f}", c[0], c[1], c[2], c[3]];
    }
}


+ (instancetype)tr_scaleImage:(UIImage *)image
                       toSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = image.size;
    CGFloat width    = imageSize.width;
    CGFloat height   = imageSize.height;
    
    CGFloat targetWidth  = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor  = 0.f;
    CGFloat scaledWidth  = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.f, 0.f);
    
    if (!CGSizeEqualToSize(imageSize, targetSize)) {
        CGFloat widthFactor  = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor;
        } else {
            scaleFactor  = heightFactor;
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5f;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5f;
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [image drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if (!newImage) {
        NSLog(@"Error: Could not scale image.");
    }
    
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (instancetype)tr_imageNamed:(NSString *)name
                withTintColor:(UIColor *)tintColor
{
    return [[[self class] imageNamed:name] tr_tintedImageWithColor:tintColor];
}

+ (instancetype)tr_imageWithInitials:(NSString *)initials size:(CGSize)size
{
    return nil;
}

+ (instancetype)tr_screenshotOfView:(UIView *)view cropRect:(CGRect)cropRect
{
    return [self tr_screenshotOfView:view
                            cropRect:cropRect
                      normalizedSize:cropRect.size];
}

+ (instancetype)tr_screenshotOfView:(UIView *)view
                           cropRect:(CGRect)cropRect
                     normalizedSize:(CGSize)normalizedSize
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect scaledCropRect = CGRectMake(cropRect.origin.x * scale, cropRect.origin.y * scale, cropRect.size.width * scale, cropRect.size.height * scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, scaledCropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    UIGraphicsBeginImageContextWithOptions(normalizedSize, NO, 1.0);
    [croppedImage drawInRect:CGRectMake(0, 0, normalizedSize.width, normalizedSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


- (UIImage *)tr_blendedOnImage:(UIImage *)image
                        onSize:(CGSize)size
                    withOffset:(CGPoint)offset
                 withTintColor:(UIColor *)tintColor
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    CGFloat originX = (self.size.width - size.width)/2 + offset.x;
    CGFloat originY = (self.size.height - size.height)/2 + offset.y;
    CGRect imageBounds = CGRectMake(originX, originY, size.width, size.height);
    [image drawInRect:imageBounds];
    
    [tintColor setFill];
    
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    [self drawInRect:bounds blendMode:kCGBlendModeOverlay alpha:1.0];
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    [self drawInRect:bounds blendMode:kCGBlendModeNormal alpha:0.9f];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+ (UIImage *)tr_tintedImageWithColor:(UIColor *)tintColor
                                size:(CGSize)size
                             rounded:(BOOL)rounded
{
    UIView *coloredView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    coloredView.backgroundColor = tintColor;
    
    if (rounded) {
        coloredView.layer.cornerRadius = size.width/2;
        coloredView.layer.masksToBounds = YES;
    }
    
    UIGraphicsBeginImageContextWithOptions(coloredView.bounds.size, NO, 0.0);
    
    [coloredView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)tr_tintedImageWithColor:(UIColor *)tintColor
{
    NSParameterAssert(tintColor);
    
    static NSCache *_tintedImageCache = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tintedImageCache = [NSCache new];
    });
    
    NSString *identifier = [NSString stringWithFormat:@"%x%@", (unsigned int)&*self, tr_NSStringFromUIColor(tintColor)];
    UIImage *image = [_tintedImageCache objectForKey:identifier];
    
    if (!image) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(context, 1.f, -1.f);
        CGContextTranslateCTM(context, 0.f, -self.size.height);
        CGContextClipToMask(context, (CGRect){CGPointZero, self.size}, self.CGImage);
        [tintColor set];
        CGContextFillRect(context, (CGRect){CGPointZero, self.size});
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [_tintedImageCache setObject:image forKey:identifier];
    }
    
    return image;
}

+ (UIImage *)tr_overlayImage:(UIImage *)foregroundImage onImage:(UIImage *)backgroundImage
{
    NSParameterAssert(foregroundImage);
    NSParameterAssert(backgroundImage);
    
    UIGraphicsBeginImageContextWithOptions(backgroundImage.size, NO, 0.0);
    [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    CGFloat foregroundPositionX = (backgroundImage.size.width - foregroundImage.size.width)/2;
    CGFloat foregroundPositionY = (backgroundImage.size.height - foregroundImage.size.height)/2;
    [foregroundImage drawInRect:CGRectMake(foregroundPositionX, foregroundPositionY, foregroundImage.size.width, foregroundImage.size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)tr_overlayImage:(UIImage *)foregroundImage onImage:(UIImage *)backgroundImage atPoint:(CGPoint)point
{
    NSParameterAssert(foregroundImage);
    NSParameterAssert(backgroundImage);
    
    UIGraphicsBeginImageContextWithOptions(backgroundImage.size, NO, 0.0);
    [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    [foregroundImage drawInRect:CGRectMake(point.x, point.y, foregroundImage.size.width, foregroundImage.size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)tr_attachImage:(UIImage *)bottomImage belowImage:(UIImage *)topImage
{
    NSParameterAssert(bottomImage);
    NSParameterAssert(topImage);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(topImage.size.width, topImage.size.height + bottomImage.size.height), NO, 0.0);
    [topImage drawInRect:CGRectMake(0.f, 0.f, topImage.size.width, topImage.size.height)];
    [bottomImage drawInRect:CGRectMake(0.f, topImage.size.height, bottomImage.size.width, bottomImage.size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)tr_roundedRectImageFromImage:(UIImage *)image
                                     size:(CGSize)imageSize
                         withCornerRadius:(float)cornerRadius
{
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    CGRect bounds=(CGRect){CGPointZero,imageSize};
    [[UIBezierPath bezierPathWithRoundedRect:bounds
                                cornerRadius:cornerRadius] addClip];
    [image drawInRect:bounds];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

+ (UIImage *)tr_imageWithColor:(UIColor *)color rect:(CGRect)rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
