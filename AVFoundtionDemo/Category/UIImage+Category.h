//
//  UIImage+Category.h
//  AVFoundtionDemo
//
//  Created by APPLE on 17/3/23.
//  Copyright © 2017年 David. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Category)


/**
 *  截取当前屏幕
 *
 *  @return NSData *
 */
+ (UIImage *)dataWithScreenshotInPNGFormatImageSize:(CGSize)imageSize;

@end
