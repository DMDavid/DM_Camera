//
//  AppDelegate+ConfigCategory.m
//  AVFoundtionDemo
//
//  Created by APPLE on 17/3/23.
//  Copyright © 2017年 David. All rights reserved.
//

#import "AppDelegate+ConfigCategory.h"
#import "iflyMSC/IFlyMSC.h"

#define APPID_VALUE           @"58d33153"

@implementation AppDelegate (ConfigCategory)

- (void)config_iflyMSC_Framework {
    //设置sdk的log等级，log保存在下面设置的工作路径中
    [IFlySetting setLogFile:LVL_ALL];
    
    //打开输出在console的log开关
    [IFlySetting showLogcat:YES];
    
    //设置sdk的工作路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    [IFlySetting setLogFilePath:cachePath];
    
    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",APPID_VALUE];
    
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];

}

@end
