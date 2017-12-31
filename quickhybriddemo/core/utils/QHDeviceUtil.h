//
//  DeviceUtil.h
//  quickhybriddemo
//
//  Created by 戴荔春 on 2017/12/31.
//  Copyright © 2017年 quickhybrid. All rights reserved.
//

#import "QHJSRegisterBaseClass.h"

@interface QHDeviceUtil : QHJSRegisterBaseClass

/**
 获取应用版本信息
 
 @return 版本号（字符串）
 */
+(NSString *)getAppVersion;

@end

