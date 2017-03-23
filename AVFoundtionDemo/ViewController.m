//
//  ViewController.m
//  AVFoundtionDemo
//
//  Created by APPLE on 17/3/6.
//  Copyright © 2017年 David. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <GPUImage/GPUImage.h>
#import "GPUImageBeautifyFilter.h"

#import "TopToolView.h"
#import "BottomToolView.h"

#define ToolViewHight 40

@interface ViewController ()

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;
@property (nonatomic, strong) TopToolView *topToolView;   //拍照上部View
@property (nonatomic, strong) BottomToolView *bottomToolView;   //拍照底部View

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.filterView];
    [self.videoCamera addTarget:self.filterView];
    
    [self.videoCamera removeAllTargets];
    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    [self.videoCamera addTarget:beautifyFilter];
    [beautifyFilter addTarget:self.filterView];
    
    [self.videoCamera startCameraCapture];
    
    [self.view addSubview:self.topToolView];
    [self.view addSubview:self.bottomToolView];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if (touch.tapCount == 1)        //单击事件
    {
        [self showAndHiddenToolViews];
        
//        [self performSelector:@selector(saveImage) withObject:nil afterDelay:0.3];
    }
    else if (touch.tapCount == 2) {
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveImage) object:nil];
//        [self changeCameraPosition];
    }
}

//显示工具栏/隐藏
- (void)showAndHiddenToolViews {
    
    if (self.topToolView.hidden) {
        [UIView animateWithDuration:0.25 animations:^{
            self.topToolView.hidden = NO;
            self.bottomToolView.hidden = NO;
            self.topToolView.transform = CGAffineTransformMakeTranslation(0, ToolViewHight);
            self.bottomToolView.transform = CGAffineTransformMakeTranslation(0, -ToolViewHight);
            
        } completion:^(BOOL finished) {
            
        }];
        
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.topToolView.transform = CGAffineTransformIdentity;
            self.bottomToolView.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            self.topToolView.hidden = YES;
            self.bottomToolView.hidden = YES;
        }];
    }
}

- (GPUImageVideoCamera *)videoCamera {
    if (!_videoCamera) {
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
        _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    }
    return _videoCamera;
}

- (GPUImageView *)filterView {
    if (!_filterView) {
        _filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
        _filterView.center = self.view.center;
    }
    return _filterView;
}

- (TopToolView *)topToolView {
    if (!_topToolView) {
        _topToolView = [[TopToolView alloc] initWithFrame:CGRectMake(0, -ToolViewHight, [UIScreen mainScreen].bounds.size.width, ToolViewHight)];
        _topToolView.hidden = YES;
        _topToolView.backgroundColor = [UIColor redColor];
    }
    return _topToolView;
}

- (BottomToolView *)bottomToolView {
    if (!_bottomToolView) {
        _bottomToolView = [[BottomToolView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, ToolViewHight)];
        _bottomToolView.hidden = YES;
        _bottomToolView.backgroundColor = [UIColor blueColor];
    }
    return _bottomToolView;
}




















// 切换摄像头
- (void)toggleCapture {
    
    // 获取当前设备方向
    AVCaptureDevicePosition position = [self.videoCamera cameraPosition];
    
//    // 获取需要改变的方向
//    AVCaptureDevicePosition togglePosition = curPosition == AVCaptureDevicePositionFront?AVCaptureDevicePositionBack:AVCaptureDevicePositionFront;
//    
//    // 获取改变的摄像头设备
//    AVCaptureDevice *toggleDevice = [self getVideoDevice:togglePosition];
//    
//    // 获取改变的摄像头输入设备
//    AVCaptureDeviceInput *toggleDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:toggleDevice error:nil];
//    
//    // 移除之前摄像头输入设备
//    [_captureSession removeInput:_currentVideoDeviceInput];
//    
//    // 添加新的摄像头输入设备
//    [_captureSession addInput:toggleDeviceInput];
//    
//    // 记录当前摄像头输入设备
//    _currentVideoDeviceInput = toggleDeviceInput;
    
}

//- (void)test {
    //    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    //    [session setSessionPreset:AVCaptureSessionPresetHigh];
    //
    //    //device
    //    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //
    //    //device input
    //    NSError *error = [[NSError alloc] init];
    //    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    //    if ( [session canAddInput:deviceInput] )
    //        [session addInput:deviceInput];
    //
    //    //preview
    //    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    //    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    //
    //    CALayer *rootLayer = [[self view] layer];
    //    [rootLayer setMasksToBounds:YES];
    //    [previewLayer setFrame:CGRectMake(-70, 0, rootLayer.bounds.size.height, rootLayer.bounds.size.height)];
    //    [rootLayer insertSublayer:previewLayer atIndex:0];
    //
    //    //开始
    //    [session startRunning];
    //    
    //    AVAudioPlayer *player = [[AVAudioPlayer alloc] init];
    //    [player play];
//}

//#pragma mark - 私有方法
//-(void)setupUI{
//    //创建播放器层
//    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//    playerLayer.frame = self.view.frame;
//    //playerLayer.videoGravity=AVLayerVideoGravityResizeAspect;//视频填充模式
//    [self.view.layer addSublayer:playerLayer];
//}
//
///**
// *  创建播放器
// *
// *  @return 音频播放器
// */
//-(AVAudioPlayer *)audioPlayer{
//    if (!_audioPlayer) {
//        NSString *urlStr=[[NSBundle mainBundle]pathForResource:@"" ofType:nil];
//        NSURL *url=[NSURL fileURLWithPath:urlStr];
//        NSError *error=nil;
//        //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
//        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
//        //设置播放器属性
//        _audioPlayer.numberOfLoops=0;//设置为0不循环
//        _audioPlayer.delegate=self;
//        [_audioPlayer prepareToPlay];//加载音频文件到缓存
//        if(error){
//            NSLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
//            return nil;
//        }
//        
//        //设置后台播放模式
//        AVAudioSession *audioSession=[AVAudioSession sharedInstance];
//        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//        //        [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
//        [audioSession setActive:YES error:nil];
//        //添加通知，拔出耳机后暂停播放
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
//    }
//    return _audioPlayer;
//}
//
//
///**
// *  播放音频
// */
//-(void)play{
//    if (![self.audioPlayer isPlaying]) {
//        [self.audioPlayer play];
//    }
//}


@end
