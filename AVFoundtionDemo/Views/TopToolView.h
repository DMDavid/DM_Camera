//
//  TopToolView.h
//  AVFoundtionDemo
//
//  Created by APPLE on 17/3/23.
//  Copyright © 2017年 David. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RotateCameraBlock)();
typedef void(^FlashButtonDidClick)(BOOL flashIsOn);

@interface TopToolView : UIView

/**
 *  旋转相机
 */
@property (nonatomic, copy) RotateCameraBlock rotateCameraBlock;

/**
 *  闪光灯点击回调
 */
@property (nonatomic, copy) FlashButtonDidClick flashButtonDidClickBlock;

@end
