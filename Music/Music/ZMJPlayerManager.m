//
//  ZMJPlayerManager.m
//  Music
//
//  Created by liuxingyu on 2017/8/15.
//  Copyright © 2017年 VinceJee. All rights reserved.
//

#import "ZMJPlayerManager.h"

@interface ZMJPlayerManager() {
    
    AVAudioPlayer *_musicPlayer;
    
    NSString *_musicName;
}

@end

@implementation ZMJPlayerManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
}

- (void)audioSessionInterruptionNotification:(NSNotification *)notification {
    AVAudioSessionInterruptionType type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] integerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [_musicPlayer pause];
    } else if (type == AVAudioSessionInterruptionTypeEnded) {
        [_musicPlayer play];
    }
}

+ (ZMJPlayerManager *)shareInstance {
    static ZMJPlayerManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZMJPlayerManager alloc] init];
    });
    return instance;
}

- (AVAudioPlayer *)playLocalMusicWithMusicName:(NSString *)filename {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
    
    NSError *err;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    
    _musicPlayer = player;
    _musicName = filename;
    
    if (err) {
        NSLog(@"function:%s err:%@",__func__,err);
    }

    return player;
}

- (void)play {
    [_musicPlayer play];
}

- (void)pause {
    [_musicPlayer pause];
}

- (void)stop {
    [_musicPlayer stop];
}


@end
