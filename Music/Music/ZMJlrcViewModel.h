//
//  ZMJlrcViewModel.h
//  Music
//
//  Created by zhumengjiao on 2017/8/9.
//  Copyright © 2017年 VinceJee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZMJlrcViewModel : NSObject

- (void)fetchLocalDataSuccess:(void (^)())success failed:(void (^)())fail withFileName:(NSString *)filename;
 
@end
