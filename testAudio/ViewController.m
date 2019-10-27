//
//  ViewController.m
//  testAudio
//
//  Created by Apple on 2019/7/11.
//  Copyright © 2019年 Apple. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<AVAudioPlayerDelegate>
//音频播放器
@property (nonatomic, strong) AVAudioPlayer *voicePlayer;
@property (nonatomic, assign) BOOL isPlayingVoice;///是否正在播放音频

@property (nonatomic, strong) NSTimer *customTimer;
@property (nonatomic, assign) NSInteger cutDownTime;
@end

@implementation ViewController
///懒加载播放器
- (AVAudioPlayer *)voicePlayer{
    //把当前播放通道设置为活跃状态
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    if (!_voicePlayer) {
        //音频文件
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"defaultAudio" ofType:@"mp3"];
        NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
        _voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];;
        _voicePlayer.volume = 1;
//        _voicePlayer.numberOfLoops = 2; //循环次数
        //这里的代理如果要用到就可以设置，没有用到就不用设置
        _voicePlayer.delegate = self;
        //这里是测试git使用的
    }
    return _voicePlayer;
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
}
- (IBAction)starCutdownTime:(id)sender {
    if (self.customTimer) {
        [self stopPlayVoiceAction];
    }
    //设置倒计时时间，倒计时结束开始播放本地音频
    self.cutDownTime = 10;
    self.customTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(cutDownTimeAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.customTimer forMode:NSRunLoopCommonModes];
}
//点击空白处停止播放
- (IBAction)stopPlay:(id)sender {
    [self stopPlayVoiceAction];
}
#pragma mark ------------------------ 倒计时时间
- (void)cutDownTimeAction{
    self.cutDownTime --;
    NSLog(@"******************************  %ld",self.cutDownTime);
    if (self.cutDownTime == 0) {
        self.isPlayingVoice = YES;
        [self.voicePlayer play];

    }
}
///停止播放音频
- (void)stopPlayVoiceAction{
    if (!self.isPlayingVoice) {
        return;
    }
    self.isPlayingVoice = NO;
    //停止播放音频
    [self.voicePlayer stop];
    //销毁定时器
    [self.customTimer invalidate];
    self.customTimer = nil;
    //恢复其他音频
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}
#pragma mark ------------------------ AVAudioPlayer的代理事件
//播放完成
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (flag) {
        //播放完成后继续从头播放
        [self.voicePlayer play];
    }
}
@end
