//
//  QHJSUiApi.m
//  quickhybriddemo
//
//  Created by 戴荔春 on 2017/12/31.
//  Copyright © 2017年 quickhybrid. All rights reserved.
//

#import "QHJSRuntimeApi.h"
#import "QHJSInfo.h"

@implementation QHJSRuntimeApi

- (void)registerHandlers {
    __weak typeof(self) weakSelf = self;
    
    [self registerHandlerName:@"getAppVersion" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *appVersion = [QHJSInfo getQHJSVersion];
        NSDictionary *dic = [weakSelf responseDicWithCode:1 Msg:@"" result:@{@"version":appVersion}];
        responseCallback(dic);
    }];
    
    [self registerHandlerName:@"getQuickVersion" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *dic = [weakSelf responseDicWithCode:1 Msg:@"" result:@{@"version":@"1.0.0"}];
        responseCallback(dic);
    }];
}

- (void)dealloc {
    NSLog(@"<QHJSRuntimeApi>dealloc");
}

@end



