//
//  TopToolView.m
//  AVFoundtionDemo
//
//  Created by APPLE on 17/3/23.
//  Copyright © 2017年 David. All rights reserved.
//

#import "TopToolView.h"

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
    UIButton *rotateCamaraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rotateCamaraBtn.frame = (CGRect){CGPointMake([UIScreen mainScreen].bounds.size.width - 10, 5), CGSizeMake(20, 20)};
    rotateCamaraBtn.imageView.image = [UIImage imageNamed:@"CameraFlip"];
    [self addSubview:rotateCamaraBtn];
    
    
}


@end
