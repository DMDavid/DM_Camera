//
//  EditPhotoViewController.h
//  AVFoundtionDemo
//
//  Created by APPLE on 17/3/27.
//  Copyright © 2017年 David. All rights reserved.
//

#import "BaseViewController.h"

@interface EditPhotoViewController : BaseViewController
{
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@property (nonatomic, strong) UIImage *takedImage;

@end
