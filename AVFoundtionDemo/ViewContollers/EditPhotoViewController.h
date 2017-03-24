//
//  EditPhotoViewController.h
//  AVFoundtionDemo
//
//  Created by APPLE on 17/3/24.
//  Copyright © 2017年 David. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditPhotoViewController : UIViewController

/**
 *  拍照获取的图片
 */
@property (nonatomic, strong) UIImage *takedImage;


@property (nonatomic, strong) NSArray *filters;

@end
