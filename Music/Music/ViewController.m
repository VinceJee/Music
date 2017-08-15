//
//  ViewController.m
//  Music
//
//  Created by zhumengjiao on 2017/8/7.
//  Copyright © 2017年 VinceJee. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>

#import "ZMJParser.h"
#import "ZMJLrcModel.h"
#import "ZMJlrcCell.h"

#import "ZMJLrcView.h"
#import "ZMJPlayerManager.h"

static NSString *cellid = @"ZMJlrcCellId";
@interface ViewController () {
    
    CADisplayLink *_lrcLink;
    CADisplayLink *_lockImageLink;
    
    __weak IBOutlet UISlider *progressSlider;
    
    ZMJLrcView *_lrcView;
}

@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation ViewController

- (IBAction)changeValue:(UISlider *)sender {
    self.player.currentTime = sender.value * self.player.duration;
}

- (void)updateLrc {
    progressSlider.value = self.player.currentTime/self.player.duration;
    _lrcView.currentTime = self.player.currentTime;
}

- (void)updateLockImage {
    [_lrcView setLockScreenImage];
}

- (void)addLockImageLink {
    [self removeLockImageLink];
    _lockImageLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLockImage)];
    [_lockImageLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)removeLockImageLink {
     [_lockImageLink invalidate];
    _lockImageLink = nil;
}

- (void)addLrcLink {
    [self removeLrcLink];
    _lrcLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrc)];
    [_lrcLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)removeLrcLink {
     [_lrcLink invalidate];
    _lrcLink = nil;
}

- (void)applicationDidEnterBackground {
    [self removeLrcLink];
    [self addLockImageLink];
}

- (void)applicationDidEnterForeground {
    [self addLrcLink];
    [self removeLockImageLink];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addLrcLink];
    [_lrcView setLockScreenImage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.player = [[ZMJPlayerManager shareInstance] playLocalMusicWithMusicName:@"陈奕迅 - 陪你度过漫长岁月 (国语).mp3"];
    [self.player prepareToPlay];
    [self.player play];
    
    
    _lrcView = [[ZMJLrcView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _lrcView.duration = self.player.duration;
    [self.view addSubview:_lrcView];
    
    
    [[MPRemoteCommandCenter sharedCommandCenter].changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        MPChangePlaybackPositionCommandEvent *ev = (MPChangePlaybackPositionCommandEvent *)event;
        
        self.player.currentTime = ev.positionTime;
        [self addLockImageLink];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[MPRemoteCommandCenter sharedCommandCenter].playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self.player play];
        [self addLrcLink];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[MPRemoteCommandCenter sharedCommandCenter].pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self.player pause];
        [self removeLrcLink];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
