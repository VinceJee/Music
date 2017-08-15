//
//  ZMJLrcView.h
//  Music
//
//  Created by liuxingyu on 2017/8/15.
//  Copyright © 2017年 VinceJee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZMJLrcView : UIView

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, assign) NSTimeInterval duration;

- (void)setLockScreenImage;

@end
