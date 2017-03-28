//
//  UIImage+Category.m
//  AVFoundtionDemo
//
//  Created by APPLE on 17/3/23.
//  Copyright © 2017年 David. All rights reserved.
//

#import "UIImage+Category.h"

@implementation UIImage (Category)

#pragma mark - 截屏

/**
 *  截取当前屏幕
 *
 *  @return NSData *
 */
+ (UIImage *)dataWithScreenshotInPNGFormatImageSize:(CGSize)imageSize targetView:(UIView *)targetView
{
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, targetView.center.x, targetView.center.y);
    CGContextConcatCTM(context, targetView.transform);
    CGContextTranslateCTM(context, -targetView.bounds.size.width * targetView.layer.anchorPoint.x, -targetView.bounds.size.height * targetView.layer.anchorPoint.y);
    
    if ([targetView respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
    {
        [targetView drawViewHierarchyInRect:targetView.bounds afterScreenUpdates:YES];
    }
    else
    {
        [targetView.layer renderInContext:context];
    }
    CGContextRestoreGState(context);
    
//    for (UIWindow *window in [[UIApplication sharedApplication] windows])
//    {
//        CGContextSaveGState(context);
//        CGContextTranslateCTM(context, window.center.x, window.center.y);
//        CGContextConcatCTM(context, window.transform);
//        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
//        
//        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
//        {
//            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
//        }
//        else
//        {
//            [window.layer renderInContext:context];
//        }
//        CGContextRestoreGState(context);
//    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
