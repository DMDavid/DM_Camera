//
//  TopToolView.m
//  AVFoundtionDemo
//
//  Created by APPLE on 17/3/23.
//  Copyright © 2017年 David. All rights reserved.
//

#import "TopToolView.h"
#import "Masonry.h"

@implementation TopToolView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}


#pragma mark - protect mothods

- (void)setupSubViews {
    //旋转摄像头
    UIButton *rotateCamaraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rotateCamaraBtn setImage:[UIImage imageNamed:@"CameraFlip"] forState:UIControlStateNormal];
    [self addSubview:rotateCamaraBtn];
    [rotateCamaraBtn addTarget:self action:@selector(rotateCameraAction) forControlEvents:UIControlEventTouchUpInside];
    
    [rotateCamaraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY).offset(5);
        make.right.equalTo(self.mas_right).offset(-20);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    
    //闪光灯
    UIButton *flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashBtn setImage:[UIImage imageNamed:@"Flashlight_On"] forState:UIControlStateNormal];
    [flashBtn setImage:[UIImage imageNamed:@"Flashlight_Off"] forState:UIControlStateSelected];
    [self addSubview:flashBtn];
    [flashBtn addTarget:self action:@selector(flashBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY).offset(5);
        make.left.equalTo(self.mas_left).offset(20);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
}

- (void)rotateCameraAction {
    if (self.rotateCameraBlock) {
        self.rotateCameraBlock();
    }
}

- (void)flashBtnDidClick:(UIButton *)button {
    button.selected = !button.selected;
    if (self.flashButtonDidClickBlock) {
        self.flashButtonDidClickBlock(button.selected);
    }
}

@end
