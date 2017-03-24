//
//  ViewController.m
//  AVFoundtionDemo
//
//  Created by APPLE on 17/3/6.
//  Copyright © 2017年 David. All rights reserved.
//

#import "DMTakePhotoViewController.h"
#import "EditPhotoViewController.h"

#import "GPUImageFourInputFilter.h"
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
//        self.isCanceled = NO; //启动发送数据线程
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
    
    NSString *text ;
    
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
    GPUImageFourInputFilter *beautifyFilter = [[GPUImageFourInputFilter alloc] init];
    [self.videoCamera addTarget:beautifyFilter];
    [beautifyFilter addTarget:self.filterView];
    
    [self.videoCamera startCameraCapture];
}

- (void)configSubViews {
    [self.view addSubview:self.topToolView];
    [self.view addSubview:self.bottomToolView];
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
        [weakSelf saveImage];
    };
}

- (void)saveImage {
    UIImage *image = [UIImage dataWithScreenshotInPNGFormatImageSize:[UIScreen mainScreen].bounds.size];
    [self loadImageFinished:image];
    
    //编辑照片控制器
    EditPhotoViewController *editPhotoViewController = [[EditPhotoViewController alloc] init];
    [self.navigationController pushViewController:editPhotoViewController animated:YES];
    editPhotoViewController.takedImage = image;
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

#pragma mark - Runtime

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

- (YYTimer *)timer {
    if (!_timer) {
        _timer = [YYTimer timerWithTimeInterval:1 target:self selector:@selector(checkVoiceControl) repeats:YES];
    }
    return _timer;
}

- (void)checkVoiceControl {
    [self startVoiceServer];
}

@end
