//
//  ZMJLrcView.m
//  Music
//
//  Created by liuxingyu on 2017/8/15.
//  Copyright © 2017年 VinceJee. All rights reserved.
//

#import "ZMJLrcView.h"
#import "ZMJlrcCell.h"
#import "ZMJLrcModel.h"
#import "ZMJParser.h"

#import <MediaPlayer/MediaPlayer.h>

static NSString *cellid = @"ZMJlrcCellId";

@interface ZMJLrcView()<UITableViewDataSource> {
    
    UITableView *_tableView;
    
    NSArray *_lrcDataSource; 
    
    NSInteger _currentIndex;
}

@end

@implementation ZMJLrcView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTableViewWithFrame:frame];
        
        _lrcDataSource = [ZMJParser parseLrcWithFileName:@"陈奕迅 - 陪你度过漫长岁月 (国语).lrc"];
    }
    return self;
}

#pragma mark - table view
- (void)setTableViewWithFrame:(CGRect)frame {
    _tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        tableView.tableFooterView = ({
            UIView *footer = [UIView new];
            footer;
        });
        
        [tableView registerNib:[UINib nibWithNibName:@"ZMJlrcCell" bundle:nil] forCellReuseIdentifier:cellid];
        tableView.separatorColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.contentInset = UIEdgeInsetsMake(self.bounds.size.height * 0.5, 0, self.bounds.size.height * 0.5, 0);
        tableView;
    });
    
    [self addSubview:_tableView];
}

#pragma mark - current time
- (void)setCurrentTime:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    [self updateLrc:currentTime];
}

#pragma mark - update lrc
- (void)updateLrc:(NSTimeInterval)currentTime {

    [_lrcDataSource enumerateObjectsUsingBlock:^(ZMJLrcModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // 当前歌词 model
        // 下行歌词
        ZMJLrcModel *modelNext = nil;
        if (idx + 1 < _lrcDataSource.count) {
            modelNext = _lrcDataSource[idx+1];
        }
        
        if (_currentIndex != idx && currentTime >= model.lrcTime && currentTime <modelNext.lrcTime) {
            
            NSIndexPath *preIndexPath = [NSIndexPath indexPathForRow:_currentIndex inSection:0];
            
            _currentIndex = idx;
            
            NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            
            [_tableView reloadRowsAtIndexPaths:@[preIndexPath,curIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            [_tableView scrollToRowAtIndexPath:curIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
        if (_currentIndex == idx) {
            
            CGFloat totalTime = modelNext.lrcTime - model.lrcTime;
            CGFloat currTime = currentTime - model.lrcTime;
            
            NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            
            ZMJlrcCell *cell = [_tableView cellForRowAtIndexPath:currentIndexPath];
            
            cell.lrcLabel.progress = currTime / totalTime;
        }
    }];
}


- (void)updateLockScreenPlayProgress {
    
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    UIImage *image = [self updateLockScreen];
    
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:image.size requestHandler:^UIImage * _Nonnull(CGSize size) {
        return image;
    }];
    
    NSDictionary *info = @{
                           MPMediaItemPropertyArtwork:artwork,
                           MPMediaItemPropertyArtist:@"陈奕迅",
                           MPMediaItemPropertyTitle:@"陪你度过漫长岁月 (国语)",
                           MPMediaItemPropertyAlbumTitle:@"专辑",
                           MPMediaItemPropertyPlaybackDuration:@(_duration),
                           MPNowPlayingInfoPropertyElapsedPlaybackTime:@(_currentTime)
                           };
    
    infoCenter.nowPlayingInfo = info;
    
}

- (void)setLockScreenImage {
    [self updateLockScreenPlayProgress];
}

- (UIImage *)updateLockScreen {
    
    NSInteger preIndex = _currentIndex - 1;
    ZMJLrcModel *preModel;
    if (preIndex>=0) {
        preModel = _lrcDataSource[preIndex];
        if ((preModel == nil || preModel.lrcString.length!=0 ) && preIndex>1) {
            preIndex = _currentIndex - 2;
            preModel = _lrcDataSource[preIndex];
        }
    }
    
    
    ZMJLrcModel *model = _lrcDataSource[_currentIndex];
    
    
    NSInteger nextIndex = _currentIndex+1;
    ZMJLrcModel *nextModel;
    if (nextIndex <_lrcDataSource.count) {
        nextModel = _lrcDataSource[nextIndex];
        if ((nextModel == nil || nextModel.lrcString.length!=0) && nextIndex+1<_lrcDataSource.count) {
            nextIndex = _currentIndex+2;
            nextModel = _lrcDataSource[nextIndex];
        }
    }
    
    UIImage *lockImage = [UIImage imageNamed:@"eason.jpg"];
    
    UIImageView *lockImageView = [[UIImageView alloc] initWithImage:lockImage];
    lockImageView.frame = CGRectMake(0, 0, lockImage.size.width, lockImage.size.height);
    
    UIView *coverView = [[UIView alloc] initWithFrame:lockImageView.frame];
    coverView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    [lockImageView addSubview:coverView];
    
    CGFloat h = 30;
    CGFloat padding = 5;
    CGFloat firstOriginY = coverView.bounds.size.height - h * 3 - padding * 3;
    
    UILabel *lrcLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, firstOriginY, coverView.bounds.size.width, h * 3)];
 
    lrcLabel.textAlignment = NSTextAlignmentCenter;
    lrcLabel.textColor = [UIColor whiteColor];
    lrcLabel.numberOfLines = 0;
    lrcLabel.text = [NSString stringWithFormat:@"%@\n%@\n%@",preModel.lrcString,model.lrcString,nextModel.lrcString];
    
    [coverView addSubview:lrcLabel];
    lockImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIGraphicsBeginImageContext(lockImageView.frame.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [lockImageView.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [lrcLabel removeFromSuperview];
    [coverView removeFromSuperview];
    [lockImageView removeFromSuperview];
    lockImageView = nil;
    
    return image;
    
}

#pragma mark - Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _lrcDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZMJlrcCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
    
    if (indexPath.row == _currentIndex) {
        cell.lrcLabel.font = [UIFont systemFontOfSize:20];
    } else {
        cell.lrcLabel.font = [UIFont systemFontOfSize:16];
        cell.lrcLabel.progress = 0.0;
    }
    
    ZMJLrcModel *model = _lrcDataSource[indexPath.row];
    cell.lrcLabel.text = model.lrcString;
    cell.lrcLabel.numberOfLines = 0;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIFont *font;
    if (indexPath.row == _currentIndex) {
        font = [UIFont systemFontOfSize:20];
    } else {
        font = [UIFont systemFontOfSize:16];
    }
    ZMJLrcModel *model = _lrcDataSource[indexPath.row];
    
    CGRect rect = [model.lrcString boundingRectWithSize:CGSizeMake(self.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return rect.size.height;
}

@end
