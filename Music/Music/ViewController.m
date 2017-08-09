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
    
    _currentIndex = 0;
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrc)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    _lrcSource = [ZMJParser parseLrcWithFileName:@"陈奕迅 - 陪你度过漫长岁月 (国语).lrc"];
    
    
    [self.view addSubview:self.lrcTableView];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"陈奕迅 - 陪你度过漫长岁月 (国语).mp3" withExtension:nil] error:nil];
    
    //    [self.player playAtTime:20];
    [self.player play];
    
    self.player.numberOfLoops = -1;
    
//    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
//    infoCenter.nowPlayingInfo = @{ MPMediaItemPropertyArtwork:[[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"eason.jpg"]],MPMediaItemPropertyArtist:@"陈奕迅",MPMediaItemPropertyTitle:@"陪你度过漫长岁月 (国语)",MPMediaItemPropertyAlbumTitle:@"专辑",MPMediaItemPropertyPlaybackDuration:@(60*4+2),};
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
