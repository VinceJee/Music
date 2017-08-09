//
//  ZMJlrcLabel.m
//  Music
//
//  Created by zhumengjiao on 2017/8/9.
//  Copyright © 2017年 VinceJee. All rights reserved.
//

#import "ZMJlrcLabel.h"

@implementation ZMJlrcLabel

- (void)setProgress:(float)progress {
    _progress = progress;
    
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    // Drawing code

    CGRect progressRect = CGRectMake(0, 0, rect.size.width * _progress, rect.size.height);
    
    [[UIColor redColor] set];
    
    UIRectFillUsingBlendMode(progressRect, kCGBlendModeSourceIn);
    
}

@end
