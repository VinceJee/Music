//
//  ZMJParser.m
//  Music
//
//  Created by zhumengjiao on 2017/8/8.
//  Copyright © 2017年 VinceJee. All rights reserved.
//

#import "ZMJParser.h"
#import "ZMJLrcModel.h"
#import "NSDateFormatter+Convenience.h"

@implementation ZMJParser

+ (NSArray *)parseLrcWithFileName:(NSString *)filename{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    
    NSError *err;
    NSString *allLrcString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    if (err) {
        NSLog(@"parse err :%@",err);
    }
    
    NSArray *allLrcArr = [allLrcString componentsSeparatedByString:@"\n"];
    
    NSString *pattern = @"\\[[0-9]{2}:[0-9]{2}.[0-9]{2}\\]";
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSMutableArray *lrcArr = [@[] mutableCopy];
    
    
    [allLrcArr enumerateObjectsUsingBlock:^(NSString *objStr, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSArray *resultArr = [regular matchesInString:objStr options:NSMatchingReportProgress range:NSMakeRange(0, objStr.length)];
        
        NSTextCheckingResult *lastResult = [resultArr firstObject]; // [xx:xx.xx]
        NSString *lrcStr = [objStr substringFromIndex:lastResult.range.location+lastResult.range.length];
        
        NSDateFormatter *formatter = [NSDateFormatter defaultFormatter];
        [formatter setDateFormat:@"[mm:ss.SS]"];
        
        NSDate *zeroDate = [formatter dateFromString:@"[00:00.00]"];
        
        for (NSTextCheckingResult *result in resultArr) {
            
            NSString *timeStr = [objStr substringWithRange:result.range];
            
            NSDate *timeDate = [formatter dateFromString:timeStr];
            
            NSTimeInterval interval = [timeDate timeIntervalSinceDate:zeroDate];

            
            if (lrcStr.length==0) {
                ZMJLrcModel *lastModel = lrcArr.lastObject;
                lastModel.lrcGoneTime += (interval - lastModel.lrcTime);
//                [lrcArr setObject:lastModel atIndexedSubscript:[lrcArr indexOfObject:lastModel]];
                continue;
            }
            
            ZMJLrcModel *model = [[ZMJLrcModel alloc] init];
            model.lrcTime = interval;
            model.lrcString = lrcStr;
            model.lrcGoneTime = interval;
            [lrcArr addObject:model]; 
         }
    }];
    
    return lrcArr;
}

@end



