//
//  ZMJParser.h
//  Music
//
//  Created by zhumengjiao on 2017/8/8.
//  Copyright © 2017年 VinceJee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZMJParser : NSObject


/**
 解析歌词

 @param filename 歌曲名称
 */
+ (NSArray *)parseLrcWithFileName:(NSString *)filename;

@end
