//
//  QHJSLocationUtil.h
//  QuickHybridDemo
//
//  Created by guanhao on 2019/3/6.
//  Copyright © 2019年 com.quickhybrid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 定位block

 @param location 位置
 @param errorStr 错误信息
 */
typedef void(^locationBlock)(CLLocation *location, NSString *errorStr);

/**
 网络请求回调block

 @param response 回调参数
 @param error 错误信息
 */
typedef void(^responseBlock)(id response, NSError *error);

@interface QHJSLocationUtil : NSObject

/**
 开始定位的方法

 @param locationBlock 回调信息
 */
- (void)startUpdateLocation:(locationBlock)locationBlock;

/**
 发送网络请求到百度，获取位置详细信息

 @param CLLocationCoordinate2D 位置信息
 @param complete 回调
 */
+ (void)getBaiduLocationInfoInLocation:(CLLocationCoordinate2D)CLLocationCoordinate2D complete:(responseBlock)complete;

@end
