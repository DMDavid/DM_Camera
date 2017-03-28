//
//  ViewController.m
//  AVFoundtionDemo
//
//  Created by APPLE on 17/3/6.
//  Copyright © 2017年 David. All rights reserved.
//

#import "DMTakePhotoViewController.h"
#import "EditPhotoViewController.h"
#import "AppDelegate.h"

#import "GPUImageBeautifyFilter.h"
#import <GPUImage/GPUImage.h>

#import "TopToolView.h"
#import "BottomToolView.h"

#import <AVFoundation/AVFoundation.h>
#import "UIImage+Category.h"
#import "MessageHUD.h"
#import <objc/runtime.h>

#import "iflyMSC/iflyMSC.h"
#import "IATConfig.h"
#import "ISRDataHelper.h"

#import "YYTimer.h"

#import "BTBalloon.h"
#import "CommonMenuView.h"

#import "AnimationView.h"

#define ToolViewHight 60

@interface DMTakePhotoViewController () <IFlySpeechRecognizerDelegate, IFlyPcmRecorderDelegate>

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;  //采集视频源
@property (nonatomic, strong) GPUImageView *filterView;          //目的源
@property (nonatomic, strong) TopToolView *topToolView;   //拍照上部View
@property (nonatomic, strong) BottomToolView *bottomToolView;   //拍照底部View

@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象
@property (nonatomic,strong) IFlyPcmRecorder *pcmRecorder;//录音器，用于音频流识别的数据传入

@property (nonatomic, strong) NSString * result;

@property (nonatomic, strong) YYTimer *timer;

/**
 *  遮盖层 (模拟相机咔嚓)
 */
@property (nonatomic, strong) UIView *coverView;

/**
 *  拍照获取的图片
 */
@property (nonatomic, strong) UIImage *takedImage;

/**
 *  动画View
 */
@property (nonatomic, strong) AnimationView *animationView;

@end

@implementation DMTakePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //采集拍照
    [self configAVCapture];
    
    //讯飞语音
    __weak typeof(self) weakSelf = self;
    self.bottomToolView.voiceControlBlock = ^ (BOOL voiceIsOn) {
        if (voiceIsOn) {
            [MessageHUD showText:@"开始语音识别"];
            
            [weakSelf startVoiceServer];
            
            [weakSelf.timer fire];
        }
        else {
            [MessageHUD showText:@"结束语音识别"];
            
            [weakSelf.iFlySpeechRecognizer stopListening];
            
            [weakSelf.timer invalidate];
        }
    };
    
    
    //弹出菜单
    [self configFunctionAction];
    
    //首次引导
    [self configFristComeToApp];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%s",__func__);
    
    [super viewWillAppear:animated];
    
    [self initRecognizer];//初始化识别对象
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s",__func__);
    
    if ([IATConfig sharedInstance].haveView == NO) {//无界面
        [_iFlySpeechRecognizer cancel]; //取消识别
        [_iFlySpeechRecognizer setDelegate:nil];
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        [_pcmRecorder stop];
        _pcmRecorder.delegate = nil;
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

//采集拍照
- (void)configAVCapture {
    //配置相机
    [self configCamera];
    
    //配置子视图
    [self configSubViews];
    
    //配置子视图事件
    [self configSubViewsAction];
}


/**
 设置识别参数
 ****/
-(void)startVoiceServer
{
    if (_iFlySpeechRecognizer.isListening) {
        return;
    }
    
    if ([IATConfig sharedInstance].haveView == YES) {
        [MessageHUD showMessage:@"请设置为无界面识别模式"];
        return;
    }
    
    if(_iFlySpeechRecognizer == nil)
    {
        [self initRecognizer];
    }

    [_iFlySpeechRecognizer setDelegate:self];
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];    //设置音频数据模式为音频流
    BOOL ret  = [_iFlySpeechRecognizer startListening];
    
    
    if (ret) {
        //初始化录音环境
        [IFlyAudioSession initRecordingAudioSession];
        
        _pcmRecorder.delegate = self;
        
        //启动录音器服务
        BOOL ret = [_pcmRecorder start];
        
//        [MessageHUD showMessage:@"正在录音" superView:self.view];
        NSLog(@"%s[OUT],Success,Recorder ret=%d",__func__,ret);
    }
    else
    {
        [MessageHUD showMessage:@"启动失败"];
        NSLog(@"%s[OUT],Failed",__func__);
    }
}

- (void)initRecognizer {
    //单例模式，无UI的实例
    if (_iFlySpeechRecognizer == nil) {
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        //设置听写模式
        [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    }
    _iFlySpeechRecognizer.delegate = self;
    
    if (_iFlySpeechRecognizer != nil) {
        IATConfig *instance = [IATConfig sharedInstance];
        
        //设置最长录音时间
        [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //设置后端点
        [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        //设置前端点
        [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        //网络等待时间
        [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        
        //设置采样率，推荐使用16K
        [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
        if ([instance.language isEqualToString:[IATConfig chinese]]) {
            //设置语言
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            //设置方言
            [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        }else if ([instance.language isEqualToString:[IATConfig english]]) {
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        }
        //设置是否返回标点符号
        [_iFlySpeechRecognizer setParameter:@"0" forKey:[IFlySpeechConstant ASR_PTT]];
        
    }
    
    //初始化录音器
    if (_pcmRecorder == nil)
    {
        _pcmRecorder = [IFlyPcmRecorder sharedInstance];
    }
    
    _pcmRecorder.delegate = self;
    
    [_pcmRecorder setSample:[IATConfig sharedInstance].sampleRate];
    
    [_pcmRecorder setSaveAudioPath:nil];    //不保存录音文件
    
}


#pragma mark - IFlySpeechRecognizerDelegate


/**
 听写结束回调（注：无论听写是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void) onError:(IFlySpeechError *) error {
    if (error.errorCode == 0 ) {
        if (_result.length == 0) {
//            text = @"无识别结果";
        }else {
//            text = @"识别成功";
            //清空识别结果
            _result = nil;
        }
    }else {
//        text = [NSString stringWithFormat:@"发生错误：%d %@", error.errorCode,error.errorDesc];
//        NSLog(@"%@",text);
    }
    
//    [MessageHUD showMessage:text superView:self.view];
}


/**
 无界面，听写结果回调
 results：听写结果
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast {
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }

    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    
    if (isLast){
        NSLog(@"听写结果(json)：%@测试",  self.result);
    }
    NSLog(@"_result=%@",_result);
    NSLog(@"resultFromJson=%@",resultFromJson);
    
    
    if([resultFromJson rangeOfString:@"拍照"].location != NSNotFound)
    {
        NSLog(@"yes");
        [self saveImage];
    }
    else
    {
        NSLog(@"no");
    }
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech
{
    NSLog(@"onEndOfSpeech");
    
    [_pcmRecorder stop];
//    [MessageHUD showMessage:@"录音结束" superView:self.view];
}


#pragma mark - IFlyPcmRecorderDelegate

- (void) onIFlyRecorderBuffer: (const void *)buffer bufferSize:(int)size
{
    NSData *audioBuffer = [NSData dataWithBytes:buffer length:size];
    
    int ret = [self.iFlySpeechRecognizer writeAudio:audioBuffer];
    if (!ret)
    {
        [self.iFlySpeechRecognizer stopListening];
        [self.timer invalidate];
        [self.bottomToolView resetVoiceButton];
//        [MessageHUD showMessage:@"录音结束" superView:self.view];
    }
}

- (void) onIFlyRecorderError:(IFlyPcmRecorder*)recoder theError:(int) error
{
    if (error) {
        [MessageHUD showMessage:@"录音失败，💔"];
    }
}

//power:0-100,注意控件返回的音频值为0-30
- (void) onIFlyRecorderVolumeChanged:(int) power
{
//    NSString * vol = [NSString stringWithFormat:@"音量：%d",power];
//    [MessageHUD showText: vol];
}


#pragma mark - 视频/采集

- (void)configCamera {
    [self.view addSubview:self.filterView];
    [self.videoCamera addTarget:self.filterView];
    
    [self.videoCamera removeAllTargets];
    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    [self.videoCamera addTarget:beautifyFilter];
    [beautifyFilter addTarget:self.filterView];
    
    [self.videoCamera startCameraCapture];
}

- (void)configSubViews {
    [self.view addSubview:self.topToolView];
    [self.view addSubview:self.bottomToolView];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.coverView];
    self.coverView.hidden = YES;
}

- (void)configSubViewsAction {
    __weak typeof(self) weakSelf = self;
    
    //旋转摄像头
    self.topToolView.rotateCameraBlock = ^{
        [weakSelf.videoCamera rotateCamera];
    };
    
    //开关闪光灯
    self.topToolView.flashButtonDidClickBlock = ^ (BOOL isFlashOn){
        Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
        if (captureDeviceClass != nil) {
            AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            if ([device hasTorch] && [device hasFlash]){

                [device lockForConfiguration:nil];
                if (isFlashOn) {
                    [device setTorchMode:AVCaptureTorchModeOn];
                    [device setFlashMode:AVCaptureFlashModeOn];

                } else {
                    [device setTorchMode:AVCaptureTorchModeOff];
                    [device setFlashMode:AVCaptureFlashModeOff];
                }
                [device unlockForConfiguration];
            }
        }
    };
    
    
    ////////////////////////////////////////////////
    //底部
    ////////////////////////////////////////////////
    
    //拍照
    self.bottomToolView.takePhotoBlock = ^ {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:IS_FRIST_PHOTO]) {
            [[BTBalloon sharedInstance] showWithTitle:@"Say 拍照 To take a photo, try it! "
                                                image:[UIImage imageNamed:@"CameraFlip"]
                                         anchorToView:weakSelf.bottomToolView.voiceContorlBtn
                                          buttonTitle:nil
                                       buttonCallback:NULL
                                           afterDelay:0.3f];
            
            //几秒后消失
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[BTBalloon sharedInstance] hide];
            });
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_FRIST_PHOTO];
        
        [weakSelf saveImage];
    };
}

- (void)saveImage {
    //咔嚓
    self.coverView.hidden = NO;
    self.coverView.alpha = 1;
    [UIView animateWithDuration:0.25 animations:^{
        self.coverView.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.coverView.hidden = YES;
    }];
    
    
    UIImage *image = [UIImage dataWithScreenshotInPNGFormatImageSize:[UIScreen mainScreen].bounds.size targetView:self.filterView];
    [self loadImageFinished:image];
    
    //赋值
    _takedImage = image;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [[BTBalloon sharedInstance] hide];
    [self removeAnimation];
    
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

#pragma mark - 保存图片

- (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    if (error) {
        [MessageHUD showMessage:@"保存失败！😢"];
        
    } else {
        
        [MessageHUD showMessage:@"保存成功！😊"];
    }
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}


#pragma mark - 功能按钮

- (void)configFunctionAction {
    __weak typeof(self) weakSelf = self;
    /**
     *  创建普通的MenuView，frame可以传递空值，宽度默认120，高度自适应
     */
    [CommonMenuView createMenuWithFrame:CGRectMake(0, 0, 150, 50) target:self dataArray:[self getMenuArrayFromTakePhotoStatus] itemsClickBlock:^(NSString *str, NSInteger tag) {
        
        //取消弹出框
        [CommonMenuView hidden];
        
        if (tag == 1) {
            //编辑照片控制器
            EditPhotoViewController *editPhotoViewController = [[EditPhotoViewController alloc] init];
            [weakSelf.navigationController pushViewController:editPhotoViewController animated:YES];
            editPhotoViewController.takedImage = weakSelf.takedImage;
            
        } else if (tag == 3) {
            [self.view addSubview:self.animationView];
        }
        
    } backViewTap:^{
        
    }];
    
    //设置功能
    self.bottomToolView.functionBlock = ^{
        //更新
        [CommonMenuView updateMenuItemsWith:[weakSelf getMenuArrayFromTakePhotoStatus]];
        
        //转换坐标系
        CGPoint centerPoint = [weakSelf.bottomToolView convertPoint:weakSelf.bottomToolView.functionButton.center toView:weakSelf.view];
        CGPoint newCenterPoint = CGPointMake(centerPoint.x, centerPoint.y - weakSelf.bottomToolView.frame.size.height/2);
        [CommonMenuView showMenuAtPoint:newCenterPoint];
    };
}

- (NSArray *)getMenuArrayFromTakePhotoStatus {
    NSArray *dataArray = nil;
    
    NSDictionary *voiceControlDict = @{@"imageName" : @"icon_button_record",
                            @"itemName" : @"  添加语音控制词"
                            };
//    if (self.takedImage) {  //显示两个按钮
//        NSDictionary *editDict = @{@"imageName" : @"icon_button_affirm",
//                                @"itemName" : @"           编辑   "
//                                };
//        dataArray = @[editDict, voiceControlDict];
//    
//    } else {
//        dataArray = @[voiceControlDict];
//    }
    
    NSDictionary *editDict = @{@"imageName" : @"icon_button_affirm",
                               @"itemName" : @"           编辑   "
                               };
    
    NSDictionary *watchAnimation = @{@"imageName" : @"icon_button_affirm",
                               @"itemName" : @"          看动画   "
                               };
    dataArray = @[editDict, voiceControlDict, watchAnimation];
    
    return dataArray;
}


#pragma mark - 首次引导

- (void)configFristComeToApp {
    //第一次来到app
    if ([[NSUserDefaults standardUserDefaults] boolForKey:IS_FRIST_ANIMATION]) {
        [self.view addSubview:self.animationView];
    }
}

- (void)removeAnimation {
    if (_animationView) {
        [_animationView removeAnimation];
        [_animationView removeFromSuperview];
        _animationView = nil;
    }
}

#pragma mark - Get

- (GPUImageVideoCamera *)videoCamera {
    if (!_videoCamera) {
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
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
        _topToolView.backgroundColor = [UIColor blackColor];
    }
    return _topToolView;
}

- (BottomToolView *)bottomToolView {
    if (!_bottomToolView) {
        _bottomToolView = [[BottomToolView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, ToolViewHight)];
        _bottomToolView.hidden = YES;
        _bottomToolView.backgroundColor = [UIColor blackColor];
    }
    return _bottomToolView;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _coverView.backgroundColor = [UIColor blackColor];
        _coverView.alpha = 0.9;
    }
    return _coverView;
}

- (YYTimer *)timer {
    if (!_timer) {
        _timer = [YYTimer timerWithTimeInterval:1 target:self selector:@selector(checkVoiceControl) repeats:YES];
    }
    return _timer;
}

- (void)checkVoiceControl {
    [self startVoiceServer];
}

- (AnimationView *)animationView {
    if (!_animationView) {
        _animationView = [[AnimationView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_FRIST_ANIMATION];
    }
    return _animationView;
}

@end
