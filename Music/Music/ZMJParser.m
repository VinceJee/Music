//
//  ZMJParser.m
//  Music
//
//  Created by zhumengjiao on 2017/8/8.
//  Copyright © 2017年 VinceJee. All rights reserved.
//

#import "ZMJParser.h"

@implementation ZMJParser

+ (NSArray *)parseLrcWithFileName:(NSString *)filename{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    
    NSError *err;
    NSString *allLrcString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    if (err) {
        NSLog(@"parse err :%@",err);
    }
    
    NSArray *allLrcArr = [allLrcString componentsSeparatedByString:@"\n"];
    
    return allLrcArr;
}

@end
