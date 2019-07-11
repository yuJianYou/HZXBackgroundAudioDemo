//
//  AppDelegate.m
//  testAudio
//
//  Created by Apple on 2019/7/11.
//  Copyright © 2019年 Apple. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
@interface AppDelegate ()
@property (strong, nonatomic) NSTimer *backgroundTime;
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configSessionOption];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //程序失去焦点的时候 开启后台服务
    [self openServiceWhenBack];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //当程序进入前台的时候结束后台任务
    [self endBackgroundTask];
}
//配置AVaudioSessionOption
- (void)configSessionOption{
    //AVAudioSessionCategoryOptionMixWithOthers:允许其他音频文件同时播放
    //AVAudioSessionCategoryOptionDuckOthers:当播放本音频时其他音频音量变小
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDuckOthers error:nil];
}
#pragma mark ---------------------------- 开启一个后台任务
- (void)openServiceWhenBack{
    UIApplication*  app = [UIApplication sharedApplication];
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
    //开启定时器 不断向系统请求后台任务执行的时间
    self.backgroundTime = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(applyForMoreTime) userInfo:nil repeats:YES];
    [self.backgroundTime fire];
    
}
//申请后台任务
-(void)applyForMoreTime {
    //如果系统给的剩余时间小于60秒 就终止当前的后台任务，再重新初始化一个后台任务，重新让系统分配时间，这样一直循环下去，保持APP在后台一直处于active状态。
    if ([UIApplication sharedApplication].backgroundTimeRemaining < 60) {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
            self.bgTask = UIBackgroundTaskInvalid;
        }];
    }
}
#pragma mark 结束一个后台任务
- (void)endBackgroundTask {
    UIApplication *app = [UIApplication sharedApplication];
    [app endBackgroundTask:self.bgTask];
    self.bgTask = UIBackgroundTaskInvalid;
    if (self.backgroundTime) {
        // 结束计时
        [self.backgroundTime invalidate];
        self.backgroundTime = nil;
    }
}
@end
