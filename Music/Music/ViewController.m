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

#import "ZMJParser.h"
#import "ZMJLrcModel.h"
#import "ZMJlrcCell.h"

static NSString *cellid = @"ZMJlrcCellId";
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource> {
    NSArray *_lrcSource;
    CADisplayLink *_displayLink;
    __weak IBOutlet UISlider *progressSlider;
    
    NSInteger _currentIndex;
}

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) UITableView *lrcTableView;

@end

@implementation ViewController

- (IBAction)changeValue:(UISlider *)sender {
    self.player.currentTime = sender.value * self.player.duration;
}

- (UITableView *)lrcTableView {
    if (!_lrcTableView) {
        _lrcTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _lrcTableView.delegate = self;
        _lrcTableView.dataSource = self;
        
        _lrcTableView.rowHeight = 30;
        _lrcTableView.separatorColor = [UIColor clearColor];
        
        [_lrcTableView registerNib:[UINib nibWithNibName:@"ZMJlrcCell" bundle:nil] forCellReuseIdentifier:cellid];
        _lrcTableView.tableFooterView = ({
            UIView *footer = [UIView new];
            footer;
        });
    }
    return _lrcTableView;
}

- (void)updateLrc {
    progressSlider.value = self.player.currentTime/self.player.duration;
    
    [_lrcSource enumerateObjectsUsingBlock:^(ZMJLrcModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // 当前歌词 model
        // 下行歌词
        ZMJLrcModel *modelNext = nil;
        if (idx + 1 < _lrcSource.count) {
            modelNext = _lrcSource[idx+1];
        }
        
        if (_currentIndex != idx && self.player.currentTime >= model.lrcTime && self.player.currentTime <modelNext.lrcTime) {

            NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            
            NSIndexPath *preIndexPath = [NSIndexPath indexPathForRow:_currentIndex inSection:0];
            
            [self.lrcTableView scrollToRowAtIndexPath:curIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            [self.lrcTableView reloadRowsAtIndexPaths:@[preIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            [self.lrcTableView reloadRowsAtIndexPaths:@[curIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            _currentIndex = idx;
        }
        
        if (_currentIndex == idx) {
            
            CGFloat totalTime = modelNext.lrcTime - model.lrcTime;
            CGFloat currTime = self.player.currentTime - model.lrcTime;
            
            NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];

            ZMJlrcCell *cell = [self.lrcTableView cellForRowAtIndexPath:currentIndexPath];
            
            cell.lrcLabel.progress = currTime / totalTime;
        }
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 测试一下是不是可以上传
    _currentIndex = 0;
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrc)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    _lrcSource = [ZMJParser parseLrcWithFileName:@"陈奕迅 - 陪你度过漫长岁月 (国语).lrc"];
    
    
    [self.view addSubview:self.lrcTableView];
    
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"陈奕迅 - 陪你度过漫长岁月 (国语).mp3" withExtension:nil] error:nil];
    
    //    [self.player playAtTime:20];
    [self.player prepareToPlay];
    [self.player play];
    self.player.meteringEnabled = YES;
    self.player.numberOfLoops = -1;
    
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    UIImage *image = [UIImage imageNamed:@"eason.jpg"];
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:image.size requestHandler:^UIImage * _Nonnull(CGSize size) {
        return image;
    }];
    
    infoCenter.nowPlayingInfo = @{
                                  MPMediaItemPropertyArtwork:artwork,
                                  MPMediaItemPropertyArtist:@"陈奕迅",
                                  MPMediaItemPropertyTitle:@"陪你度过漫长岁月 (国语)",
                                  MPMediaItemPropertyAlbumTitle:@"专辑",
                                  MPMediaItemPropertyPlaybackDuration:@(self.player.duration),
                                  MPNowPlayingInfoPropertyElapsedPlaybackTime:@(self.player.currentTime)
                                  };
    
    NSDate *date = [NSDate date];
    
    [[MPRemoteCommandCenter sharedCommandCenter].changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
//        self.player.currentTime = event.timestamp - [date timeIntervalSince1970];
//        
//        [self.player prepareToPlay];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[MPRemoteCommandCenter sharedCommandCenter].playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self.player play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[MPRemoteCommandCenter sharedCommandCenter].pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self.player pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[MPRemoteCommandCenter sharedCommandCenter].previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[MPRemoteCommandCenter sharedCommandCenter].nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
//    
//    [[MPRemoteCommandCenter sharedCommandCenter].bookmarkCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
//        return MPRemoteCommandHandlerStatusSuccess;
//    }];
    
}

#pragma mark - table view delegate & data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _lrcSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZMJlrcCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
    
    if (_currentIndex == indexPath.row) {
        cell.lrcLabel.font = [UIFont systemFontOfSize:20];
    } else {
        cell.lrcLabel.progress = 0.0;
        cell.lrcLabel.font = [UIFont systemFontOfSize:16];
    }

    cell.lrcLabel.text = [_lrcSource[indexPath.row] lrcString];
    return cell;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
//    [super remoteControlReceivedWithEvent:event];
//    UIEventSubtypeNone                              = 0,
//    
//    // for UIEventTypeMotion, available in iPhone OS 3.0
//    UIEventSubtypeMotionShake                       = 1,
//    
//    // for UIEventTypeRemoteControl, available in iOS 4.0
//    UIEventSubtypeRemoteControlPlay                 = 100, // 播放
//    UIEventSubtypeRemoteControlPause                = 101, // 暂停
//    UIEventSubtypeRemoteControlStop                 = 102,
//    UIEventSubtypeRemoteControlTogglePlayPause      = 103,
//    UIEventSubtypeRemoteControlNextTrack            = 104, // 下一首
//    UIEventSubtypeRemoteControlPreviousTrack        = 105, // 上一首
//    UIEventSubtypeRemoteControlBeginSeekingBackward = 106,
//    UIEventSubtypeRemoteControlEndSeekingBackward   = 107,
//    UIEventSubtypeRemoteControlBeginSeekingForward  = 108,
//    UIEventSubtypeRemoteControlEndSeekingForward    = 109,
    
    NSLog(@"---%zd",event.subtype);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
