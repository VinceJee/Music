//
//  ZMJPlayerManager.h
//  Music
//
//  Created by liuxingyu on 2017/8/15.
//  Copyright © 2017年 VinceJee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

@interface ZMJPlayerManager : NSObject

+ (ZMJPlayerManager *)shareInstance;

- (AVAudioPlayer *)playLocalMusicWithMusicName:(NSString *)filename;

- (void)pause;

- (void)play;

- (void)stop;

@end
