//
//  BottomToolView.m
//  AVFoundtionDemo
//
//  Created by APPLE on 17/3/23.
//  Copyright © 2017年 David. All rights reserved.
//

#import "BottomToolView.h"
#import "Masonry.h"

@implementation BottomToolView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupSubViews];
    }
    return self;
}


#pragma mark - protect mothods

- (void)setupSubViews {
    //设置功能
    UIButton *functionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [functionBtn setImage:[UIImage imageNamed:@"filtericon"] forState:UIControlStateNormal];
    [self addSubview:functionBtn];
    [functionBtn addTarget:self action:@selector(functionBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.functionButton = functionBtn;
    
    [functionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.mas_left).offset(20);
        make.width.equalTo(@60);
        make.height.equalTo(@60);
    }];
    
    //拍照按钮
    UIButton *takeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [takeBtn setImage:[UIImage imageNamed:@"takePhoto"] forState:UIControlStateNormal];
    [self addSubview:takeBtn];
    [takeBtn addTarget:self action:@selector(takePhotoAction) forControlEvents:UIControlEventTouchUpInside];
    
    [takeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    //启动语音识别
    UIButton *voiceContorlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.voiceContorlBtn = voiceContorlBtn;
    [voiceContorlBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [voiceContorlBtn setImage:[UIImage imageNamed:@"check-symbol"] forState:UIControlStateSelected];
    [self addSubview:voiceContorlBtn];
    [voiceContorlBtn addTarget:self action:@selector(openVoiceControl:) forControlEvents:UIControlEventTouchUpInside];
    
    [voiceContorlBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-20);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    
}

- (void)resetVoiceButton {
    self.voiceContorlBtn.selected = NO;
}

- (void)functionBtnDidClick:(UIButton *)btn {
    if (self.functionBlock) {
        self.functionBlock();
    }
}

- (void)takePhotoAction {
    if (self.takePhotoBlock) {
        self.takePhotoBlock();
    }
}

- (void)openVoiceControl:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (self.voiceControlBlock) {
        self.voiceControlBlock(btn.selected);
    }
}

@end
