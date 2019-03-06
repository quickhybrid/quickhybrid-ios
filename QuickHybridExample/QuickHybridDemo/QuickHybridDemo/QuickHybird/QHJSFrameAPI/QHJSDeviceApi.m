//
//  QHJSDeviceApi.m
//  quickhybriddemo
//
//  Created by 戴荔春 on 2017/12/31.
//  Copyright © 2017年 quickhybrid. All rights reserved.
//

#import "QHJSDeviceApi.h"
#import "QHJSDeviceInfo.h"
#import <MessageUI/MessageUI.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation QHJSDeviceApi

- (void)registerHandlers {
    __weak typeof(self) weakSelf = self;
    
    //屏幕旋转方向
    [self registerHandlerName:@"setOrientation" handler:^(id data, WVJBResponseCallback responseCallback) {
        
    }];
    
    //获取设备id
    [self registerHandlerName:@"getDeviceId" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *deviceId = [QHJSDeviceInfo getDeviceId];
        NSDictionary *resultDic = @{@"deviceId" : deviceId};
        NSDictionary *backDic = @{@"result" : resultDic, @"code" : @1, @"msg" : @""};
        responseCallback(backDic);
    }];
    
    //获取设备信息
    [self registerHandlerName:@"getVendorInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        //获取设备供应商相关信息
        NSDictionary *resultDic = [QHJSDeviceInfo getDeviceInfo];
        NSDictionary *backDic = @{@"result":resultDic, @"code":@1, @"msg":@""};
        responseCallback(backDic);
    }];
    
    //获取网络状态
    [self registerHandlerName:@"getNetWorkInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        //需要集成Reachability工具
        NSNumber *result = [QHJSDeviceInfo getNetWorkType];
        NSDictionary *resultDic = @{@"netWorkType":result};
        NSDictionary *backDic = @{@"result":resultDic, @"code":@1, @"msg":@""};
        responseCallback(backDic);
    }];
    
    //打电话
    [self registerHandlerName:@"callPhone" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *phoneNum = data[@"phoneNum"];
        NSString *callStr = [NSString stringWithFormat:@"telprompt://%@", phoneNum];
        NSURL *url = [NSURL URLWithString:callStr];
        
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication ] openURL:url options:@{} completionHandler:^(BOOL success) {
                
            }];
        } else {
            [[UIApplication sharedApplication ] openURL:url];
        }
    }];
    
    //发送短信
    [self registerHandlerName:@"sendMsg" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *phoneNum = data[@"phoneNum"];
        NSString *message = data[@"message"];
        MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc] init];
        //设置短信内容
        messageVC.body = message;
        //设置收件人列表
        messageVC.recipients = @[phoneNum];
        //设置代理
        messageVC.messageComposeDelegate = weakSelf.webloader;
        [weakSelf.webloader presentViewController:messageVC animated:YES completion:nil];
    }];
    
    //回收键盘
    [self registerHandlerName:@"closeInputKeyboard" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf.webloader.view endEditing:YES];
        NSDictionary *dic = [weakSelf responseDicWithCode:1 Msg:@"关闭成功" result:nil];
        responseCallback(dic);
    }];
    
    //震动
    [self registerHandlerName:@"vibrate" handler:^(id data, WVJBResponseCallback responseCallback) {
        //参数duration默认是500ms，iOS不支持时间设置
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }];
}

- (void)dealloc {
    NSLog(@"<QHJSDeviceApi>dealloc");
}

@end



