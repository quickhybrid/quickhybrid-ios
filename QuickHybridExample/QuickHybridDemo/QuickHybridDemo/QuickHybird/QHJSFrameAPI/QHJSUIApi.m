//
//  QHJSRuntimeApi.m
//  quickhybriddemo
//
//  Created by guanhao on 2017/12/31.
//  Copyright © 2017年 quickhybrid. All rights reserved.
//

#import "QHJSUIApi.h"
#import "QHJSToast.h"
#import "QHJSDatePickViewController.h"

@implementation QHJSUIApi

- (void)registerHandlers {
    
    __weak typeof(self) weakSelf = self;
    
    //弹框提示
    [self registerHandlerName:@"toast" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *message = data[@"message"];
        NSString *duration = data[@"duration"];
        if ([duration isEqualToString:@"long"]) {
            // 暂时不支持设置长时间显示
        }
        QHJSToast *toast = [QHJSToast toastMessage:message duration:2];
        [toast show];
        
        NSDictionary *resDic = [weakSelf responseDicWithCode:1 Msg:@"" result:nil];
        responseCallback(resDic);
    }];
    
    //原生alert
    [self registerHandlerName:@"showDebugDialog" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *debugInfo = [data objectForKey:@"debugInfo"];
        if (debugInfo.length == 0) {
            NSDictionary *errorDic = [weakSelf responseDicWithCode:0 Msg:@"debugInfo不存在" result:nil];
            responseCallback(errorDic);
            return;
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"debugInfo" message:debugInfo preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:cancelAction];
        
        UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"复制" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = debugInfo;
        }];
        [alertController addAction:copyAction];
        [weakSelf.webloader presentViewController:alertController animated:YES completion:nil];
    }];
    
    // alert Api 实际调用的是confirm Api
    [self registerHandlerName:@"confirm" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *title = [data objectForKey:@"title"];
        NSString *message = [data objectForKey:@"message"];
        NSArray *buttons = [data objectForKey:@"buttonLabels"];
        
        if (buttons.count == 0) {
            NSDictionary *responseDic = [weakSelf responseDicWithCode:0 Msg:@"未设置button" result:nil];
            responseCallback(responseDic);
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            for (int i = 0; i < buttons.count; i++) {
                UIAlertAction *action = [UIAlertAction actionWithTitle:buttons[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSDictionary *result = @{@"which" : @(i)};
                    NSDictionary *responseDic = [weakSelf responseDicWithCode:1 Msg:@"" result:result];
                    responseCallback(responseDic);
                }];
                [alertController addAction:action];
            }
            [weakSelf.webloader presentViewController:alertController animated:YES completion:nil];
        }
    }];
    
    [self registerHandlerName:@"showWaiting" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *message = data[@"message"];
        if (message) {
            [weakSelf.webloader showProgressWithMessage:message];
        } else {
            [weakSelf.webloader showProgressWithMessage:nil];
        }
        NSDictionary *dic = [weakSelf responseDicWithCode:1 Msg:@"" result:nil];
        responseCallback(dic);
    }];
    
    [self registerHandlerName:@"closeWaiting" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf.webloader hideProgress];
        NSDictionary *dic = [weakSelf responseDicWithCode:1 Msg:@"" result:nil];
        responseCallback(dic);
    }];
    
    // 原生的actionSheet
    [self registerHandlerName:@"actionSheet" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *title = data[@"title"];
        NSArray *items = data[@"items"];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
        for (int i = 0; i < items.count; i++) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:items[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSDictionary *result = @{@"which" : @(i)};
                NSDictionary *responseDic = [weakSelf responseDicWithCode:1 Msg:@"" result:result];
                responseCallback(responseDic);
            }];
            [alertController addAction:action];
        }
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:cancelAction];
        [weakSelf.webloader presentViewController:alertController animated:YES completion:nil];
    }];
    
    // 原生的日期选择器
    [self registerHandlerName:@"pickDate" handler:^(id data, WVJBResponseCallback responseCallback) {
        QHJSDatePickViewController *datePickerController = [[QHJSDatePickViewController alloc] init];
        datePickerController.datePickerMode = QHJSDatePickerDate;
        datePickerController.defaultDateTime = data[@"datetime"];
        datePickerController.titleStr = data[@"title"];
        datePickerController.selectBlock = ^(NSString *dateTimeStr) {
            NSDictionary *result = @{@"date":dateTimeStr};
            NSDictionary *responseDic = [weakSelf responseDicWithCode:1 Msg:@"" result:result];
            responseCallback(responseDic);
        };
        [datePickerController showByModalInController:weakSelf.webloader];
    }];
    
    // 原生的时间选择器
    [self registerHandlerName:@"pickTime" handler:^(id data, WVJBResponseCallback responseCallback) {
        QHJSDatePickViewController *datePickerController = [[QHJSDatePickViewController alloc] init];
        datePickerController.datePickerMode = QHJSDatePickerModeTime;
        datePickerController.defaultDateTime = data[@"datetime"];
        datePickerController.titleStr = data[@"title"];
        datePickerController.selectBlock = ^(NSString *dateTimeStr) {
            NSDictionary *result = @{@"time":dateTimeStr};
            NSDictionary *responseDic = [weakSelf responseDicWithCode:1 Msg:@"" result:result];
            responseCallback(responseDic);
        };
        [datePickerController showByModalInController:weakSelf.webloader];
    }];
    
    [self registerHandlerName:@"pickDateTime" handler:^(id data, WVJBResponseCallback responseCallback) {
        QHJSDatePickViewController *datePickerController = [[QHJSDatePickViewController alloc] init];
        datePickerController.datePickerMode = QHJSDatePickerDateAndTime;
        datePickerController.defaultDateTime = data[@"datetime"];
        datePickerController.titleStr = [NSString stringWithFormat:@"%@和%@", data[@"title1"], data[@"title2"]];
        datePickerController.selectBlock = ^(NSString *dateTimeStr) {
            NSDictionary *result = @{@"datetime":dateTimeStr};
            NSDictionary *responseDic = [weakSelf responseDicWithCode:1 Msg:@"" result:result];
            responseCallback(responseDic);
        };
        [datePickerController showByModalInController:weakSelf.webloader];
    }];
}

- (void)dealloc {
    NSLog(@"<QHJSUIApi>dealloc");
}

@end



