//
//  AnimationView.m
//  AVFoundtionDemo
//
//  Created by APPLE on 17/3/28.
//  Copyright © 2017年 David. All rights reserved.
//

#import "AnimationView.h"
#import <Lottie/Lottie.h>

@interface AnimationView()

@property (nonatomic, strong) LOTAnimationView *lottieAniamtion;

@end

@implementation AnimationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews:frame];
    }
    return self;
}

- (void)setupSubViews:(CGRect)frame {
    self.backgroundColor = [UIColor whiteColor];
    
    NSString *fileURL = [[NSBundle mainBundle] pathsForResourcesOfType:@"json" inDirectory:nil].lastObject;
    NSArray *components = [fileURL componentsSeparatedByString:@"/"];

    self.lottieAniamtion = [LOTAnimationView animationNamed:components.lastObject];
    self.lottieAniamtion.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.lottieAniamtion];
    [self.lottieAniamtion setFrame:frame];
    [self setNeedsLayout];
    
    [self.lottieAniamtion play];
    
    __weak typeof(self) weakSelf = self;
    [self.lottieAniamtion playWithCompletion:^(BOOL animationFinished) {
        [weakSelf removeAnimation];
    }];
}

- (void)removeAnimation {
    [self.lottieAniamtion pause];
    [self removeFromSuperview];
}

@end
