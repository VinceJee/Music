//
//  NSDateFormatter+Convenience.m
//  Music
//
//  Created by zhumengjiao on 2017/8/9.
//  Copyright © 2017年 VinceJee. All rights reserved.
//

#import "NSDateFormatter+Convenience.h"

@implementation NSDateFormatter (Convenience)

+ (NSDateFormatter *)defaultFormatter {
    static dispatch_once_t onceToken;
    static NSDateFormatter *formatter = nil;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
    });
    return formatter;
}

@end
