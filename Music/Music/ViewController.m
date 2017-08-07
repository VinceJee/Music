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

@interface ViewController ()

@property (nonatomic, strong) AVAudioPlayer *player;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"陈奕迅 - 陪你度过漫长岁月 (国语).mp3" withExtension:nil] error:nil];
    
    //    [self.player playAtTime:20];
    [self.player play];
    
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    infoCenter.nowPlayingInfo = @{
                                  MPMediaItemPropertyArtwork:[[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"eason.jpg"]],
                                  MPMediaItemPropertyArtist:@"陈奕迅",
                                  MPMediaItemPropertyTitle:@"陪你度过漫长岁月 (国语)",
                                  MPMediaItemPropertyAlbumTitle:@"专辑",
                                  //                                  MPMediaItemPropertyAlbumTrackCount:@(1),
                                  //                                  MPMediaItemPropertyAlbumTrackNumber:@(2),
                                  //                                  MPMediaItemPropertyComposer:@"作曲家",
                                  //                                  MPMediaItemPropertyDiscCount:@(3),
                                  //                                  MPMediaItemPropertyDiscNumber:@(4),
                                  //                                  MPMediaItemPropertyGenre:@"流派",
                                  //                                  MPMediaItemPropertyPersistentID:@"PersistentID",
                                  MPMediaItemPropertyPlaybackDuration:@(60*4+2),
                                  };
    
    /*
     设置数据时对应的Key
     
     currently supported include 主要的
     
     // MPMediaItemPropertyAlbumTitle       专辑标题
     // MPMediaItemPropertyAlbumTrackCount  专辑歌曲数
     // MPMediaItemPropertyAlbumTrackNumber 专辑歌曲编号
     // MPMediaItemPropertyArtist           艺术家/歌手
     // MPMediaItemPropertyArtwork          封面图片 MPMediaItemArtwork类型
     // MPMediaItemPropertyComposer         作曲
     // MPMediaItemPropertyDiscCount        专辑数
     // MPMediaItemPropertyDiscNumber       专辑编号
     // MPMediaItemPropertyGenre            类型/流派
     // MPMediaItemPropertyPersistentID     唯一标识符
     // MPMediaItemPropertyPlaybackDuration 歌曲时长  NSNumber类型
     // MPMediaItemPropertyTitle            歌曲名称
     
     Additional metadata properties 额外的
     
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyElapsedPlaybackTime  当前时间 NSNumber
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyPlaybackRate
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyDefaultPlaybackRate
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyPlaybackQueueIndex
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyPlaybackQueueCount
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyChapterNumber
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyChapterCount
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyAvailableLanguageOptions   MPNowPlayingInfoLanguageOptionGroup
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyCurrentLanguageOptions
     */
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
