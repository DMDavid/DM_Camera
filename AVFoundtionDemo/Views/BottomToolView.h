//
//  BottomToolView.h
//  AVFoundtionDemo
//
//  Created by APPLE on 17/3/23.
//  Copyright © 2017年 David. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TakePhotoBlock)();
typedef void(^VoiceControlBlock)(BOOL voiceIsOn);

@interface BottomToolView : UIView

/**
 *  拍照
 */
@property (nonatomic, copy) TakePhotoBlock takePhotoBlock;

/**
 *  声音控制
 */
@property (nonatomic, copy) VoiceControlBlock voiceControlBlock;

/**
 *  音频控制按钮
 */
@property (nonatomic, strong) UIButton *voiceContorlBtn;

- (void)resetVoiceButton;

@end
