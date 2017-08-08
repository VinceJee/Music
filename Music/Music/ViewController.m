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


@interface ViewController ()<UITableViewDelegate, UITableViewDataSource> {
    NSArray *_lrcSource;
    NSTimer *_timer;
    __weak IBOutlet UISlider *progressSlider;
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
    }
    return _lrcTableView;
}

- (void)updateLrc {
    progressSlider.value = self.player.currentTime/self.player.duration;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
     
    
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateLrc) userInfo:nil repeats:YES];
    _lrcSource = [ZMJParser parseLrcWithFileName:@"陈奕迅 - 陪你度过漫长岁月 (国语).lrc"];
    
    [self.view addSubview:self.lrcTableView];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"陈奕迅 - 陪你度过漫长岁月 (国语).mp3" withExtension:nil] error:nil];
    
    //    [self.player playAtTime:20];
    [self.player play];
    
    self.player.numberOfLoops = -1;
    
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    infoCenter.nowPlayingInfo = @{
                                  MPMediaItemPropertyArtwork:[[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"eason.jpg"]],
                                  MPMediaItemPropertyArtist:@"陈奕迅",
                                  MPMediaItemPropertyTitle:@"陪你度过漫长岁月 (国语)",
                                  MPMediaItemPropertyAlbumTitle:@"专辑",
                                 
                                  MPMediaItemPropertyPlaybackDuration:@(60*4+2),
                                  };
}

#pragma mark - table view delegate & data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _lrcSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellid = @"lrcCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    cell.textLabel.text = _lrcSource[indexPath.row];
    return cell;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
