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
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource,AVAudioPlayerDelegate> {
    
    NSArray *_lrcModelSource;
    
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
        
        _lrcTableView.center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height * 0.5);
        _lrcTableView.contentInset = UIEdgeInsetsMake(self.view.bounds.size.height * 0.3, 0, 0, 0);
    }
    return _lrcTableView;
}

- (void)updateLrc {
    progressSlider.value = self.player.currentTime/self.player.duration;

//    for (NSInteger idx=0; idx<_lrcModelSource.count; idx++) 
    
    [_lrcModelSource enumerateObjectsUsingBlock:^(ZMJLrcModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // 当前歌词 model
        // 下行歌词
        ZMJLrcModel *modelNext = nil;
        if (idx + 1 < _lrcModelSource.count) {
            modelNext = _lrcModelSource[idx+1];
        }
        
        if (_currentIndex != idx && self.player.currentTime >= model.lrcTime && self.player.currentTime <modelNext.lrcTime) {
            
            NSIndexPath *preIndexPath = [NSIndexPath indexPathForRow:_currentIndex inSection:0];
            
            _currentIndex = idx;
            
            NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            
            [self.lrcTableView reloadRowsAtIndexPaths:@[preIndexPath,curIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            [self.lrcTableView scrollToRowAtIndexPath:curIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
        if (_currentIndex == idx) {
            
            CGFloat totalTime = modelNext.lrcTime - model.lrcTime;
            CGFloat currTime = self.player.currentTime - model.lrcTime;
            
            NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            
            ZMJlrcCell *cell = [self.lrcTableView cellForRowAtIndexPath:currentIndexPath];
            
            cell.lrcLabel.progress = currTime / totalTime;
        }
    }];
    
//    [self changeLockScreenProgress];
}

- (void)changeLockScreenProgress {
    
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    UIImage *image = [self updateLockScreenLrc];
    
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
    
}

- (void)audioSessionInterruptionNotification:(NSNotification *)notification {
    AVAudioSessionInterruptionType type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] integerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [self.player pause];
    } else if (type == AVAudioSessionInterruptionTypeEnded) {
        [self.player play];
    }
}

- (void)end {
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)start {
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrc)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)test1 {
    UIImage *lockImage = [UIImage imageNamed:@"eason.jpg"];

    CGRect rect = CGRectMake(100, 100, 100, 100);
    [[UIColor redColor]set];
    UIRectFill(rect);
               
    UIRectFrameUsingBlendMode(rect, kCGBlendModeColor);
    
    UIImageView *imagev = [[UIImageView alloc] initWithImage:lockImage];
    imagev.frame = rect;
    [self.view addSubview:imagev];
}

- (void)test {
   
    UIImage *image1 = [UIImage imageNamed:@"eason.jpg"];
    UIImage *image2 = [UIImage imageNamed:@"eason.jpg"];
    
    UIGraphicsBeginImageContext(CGRectMake(0, 0, 100, 100).size);
    
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, 100, 100)];
    
    // Draw image2
    [image2 drawInRect:CGRectMake(0, 30, 100, 100)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImageView *imagev = [[UIImageView alloc] initWithImage:resultingImage];
    
    imagev.frame = CGRectMake(100, 100, 200, 200);
    
    [imagev.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    [self.view addSubview:imagev];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self start];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];

    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    
    // 测试一下是不是可以上传
    _currentIndex = 0;
    
    _lrcModelSource = [ZMJParser parseLrcWithFileName:@"陈奕迅 - 陪你度过漫长岁月 (国语).lrc"];
 
    [self.view addSubview:self.lrcTableView];
    
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"陈奕迅 - 陪你度过漫长岁月 (国语).mp3" withExtension:nil] error:nil];
    
    self.player.delegate = self;
    //    [self.player playAtTime:20];
    [self.player prepareToPlay];
    [self.player play];
//    self.player.meteringEnabled = YES;
//    self.player.numberOfLoops = -1;
    
    [self changeLockScreenProgress];

    
    [[MPRemoteCommandCenter sharedCommandCenter].changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        
        MPChangePlaybackPositionCommandEvent *ev = (MPChangePlaybackPositionCommandEvent *)event;
        
        self.player.currentTime = ev.positionTime;
        [self changeLockScreenProgress];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[MPRemoteCommandCenter sharedCommandCenter].playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self.player play];
        [self start];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[MPRemoteCommandCenter sharedCommandCenter].pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [self.player pause];
        [self end];
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
    return _lrcModelSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZMJlrcCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
    
    if (indexPath.row == _currentIndex) {
        cell.lrcLabel.font = [UIFont systemFontOfSize:20];
    } else {
        cell.lrcLabel.font = [UIFont systemFontOfSize:16];
        cell.lrcLabel.progress = 0.0;
    }
    
    ZMJLrcModel *model = _lrcModelSource[indexPath.row];
    cell.lrcLabel.text = model.lrcString;
    
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

#pragma mark - AVAudioPlayerDelgate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self changeLockScreenProgress];
    [self.player play];
}

- (UIImage *)updateLockScreenLrc {
    
    NSInteger preIndex = _currentIndex - 1;
    ZMJLrcModel *preModel;
    if (preIndex>=0) {
        preModel = _lrcModelSource[preIndex];
        if (!preModel.lrcString && preIndex>1) {
            preIndex = _currentIndex - 2;
            preModel = _lrcModelSource[preIndex];
        }
    }
    ZMJLrcModel *model = _lrcModelSource[_currentIndex];
    
    NSInteger nextIndex = _currentIndex+1;
    ZMJLrcModel *nextModel;
    if (nextIndex <_lrcModelSource.count) {
        nextModel = _lrcModelSource[nextIndex];
        if (!nextModel.lrcString && nextIndex+1<_lrcModelSource.count) {
            nextIndex = _currentIndex+2;
            nextModel = _lrcModelSource[nextIndex];
        }
    }
    
    UIImage *lockImage = [UIImage imageNamed:@"eason.jpg"];

    UIImageView *lockImageView = [[UIImageView alloc] initWithImage:lockImage];
    lockImageView.frame = CGRectMake(0, 0, lockImage.size.width, lockImage.size.height);
    
    UIView *coverView = [[UIView alloc] initWithFrame:lockImageView.frame];
    
    CGFloat h = 30;
    CGFloat padding = 5;
    CGFloat firstOriginY = coverView.bounds.size.height - h * 3 - padding * 3;
    
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, firstOriginY, coverView.bounds.size.width, h)];
    
    UILabel *secLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, firstOriginY + h + padding, coverView.bounds.size.width, h)];
    
    UILabel *thirdLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, firstOriginY + 2 * h + 2 * padding, coverView.bounds.size.width, h)];
    
    thirdLabel.textColor = [UIColor blackColor];
    
    firstLabel.textColor = [UIColor blackColor];
    
    secLabel.textColor = [UIColor blackColor];
    
    firstLabel.textAlignment = NSTextAlignmentCenter;
    secLabel.textAlignment = NSTextAlignmentCenter;
    thirdLabel.textAlignment = NSTextAlignmentCenter;
    
    firstLabel.text = preModel.lrcString;
    secLabel.text = model.lrcString;
    thirdLabel.text = nextModel.lrcString;
    
    [coverView addSubview:firstLabel];
    [coverView addSubview:secLabel];
    [coverView addSubview:thirdLabel];
    
    firstLabel.backgroundColor = [UIColor redColor];
    secLabel.backgroundColor = [UIColor yellowColor];
    thirdLabel.backgroundColor = [UIColor greenColor];
    
    coverView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    
    [lockImageView addSubview:coverView];
    lockImageView.contentMode = UIViewContentModeScaleAspectFit;

    
    UIGraphicsBeginImageContext(lockImageView.frame.size);
    
    [lockImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
