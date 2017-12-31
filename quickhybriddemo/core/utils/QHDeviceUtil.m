//
//  DeviceUtil.m
//  quickhybriddemo
//
//  Created by 戴荔春 on 2017/12/31.
//  Copyright © 2017年 quickhybrid. All rights reserved.
//

#import "QHDeviceUtil.h"

@implementation QHDeviceUtil

+(NSString *)getAppVersion{
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
}

@end
