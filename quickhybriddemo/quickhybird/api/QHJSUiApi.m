//
//  QHJSRuntimeApi.m
//  quickhybriddemo
//
//  Created by 戴荔春 on 2017/12/31.
//  Copyright © 2017年 quickhybrid. All rights reserved.
//

#import "QHJSUiApi.h"
#import "QHBaseWebLoader.h"
#import "QHToast.h"

@implementation QHJSUiApi

- (void)registerHandlers {
    [self registerHandlerName:@"toast" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *message = data[@"message"];
        NSString *duration = data[@"duration"];
        if ([duration isEqualToString:@"long"]) {
            // 暂时不支持设置长时间显示
        }
        QHToast *toast =  [QHToast toastMessage:message duration:2];
        [toast show];
        
        NSDictionary *resDic = [self responseDicWithCode:1 Msg:@"" result:nil];
        responseCallback(resDic);
    }];
}
@end



