//
//  QHJSDeviceInfo.h
//  QuickHybridDemo
//
//  Created by guanhao on 2019/3/6.
//  Copyright © 2019年 com.quickhybrid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QHJSDeviceInfo : NSObject

/**
 获取设备id
 */
+ (NSString *)getDeviceId;

/**
 获取网络状态
 */
+ (NSNumber *)getNetWorkType;

/**
 获取设备整体状态
 */
+ (NSDictionary *)getDeviceInfo;

@end
