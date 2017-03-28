//
//  AppDelegate.m
//  AVFoundtionDemo
//
//  Created by APPLE on 17/3/6.
//  Copyright © 2017年 David. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+ConfigCategory.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    //讯飞sdk配置
    [self config_iflyMSC_Framework];
    
    //首次引导
    if (![[NSUserDefaults standardUserDefaults] valueForKey:IS_FRIST_ANIMATION]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_FRIST_ANIMATION];
    }
    //首次拍照
    if (![[NSUserDefaults standardUserDefaults] valueForKey:IS_FRIST_PHOTO]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_FRIST_PHOTO];
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
