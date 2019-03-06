//
//  QHJSAuthApi.m
//  quickhybriddemo
//
//  Created by 戴荔春 on 2017/12/31.
//  Copyright © 2017年 quickhybrid. All rights reserved.
//

#import "QHJSAuthApi.h"
#import "QHJSBaseWebLoader.h"

@implementation QHJSAuthApi

- (void)registerHandlers {
    
    __weak typeof(self) weakSelf = self;
    
    //获取token方法
    [self registerHandlerName:@"getToken" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *token = @"testtoken";
        if (token.length == 0) {
            token = @"";
        }
        NSDictionary *resultDic = @{@"access_token" : token};
        NSDictionary *responData = @{@"result" : resultDic, @"code" : @1, @"msg" : @"token"};
        responseCallback(responData);
    }];
    
    //设置自定义API的方法
    [self registerHandlerName:@"config" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSInteger configSuccess = 1;
        NSString *msg = @"";
        id listArray = [data objectForKey:@"jsApiList"];
        if ([listArray isKindOfClass:[NSArray class]]) {
            //获取配置文件
            NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"QHJSModules" ofType:@"plist"];
            NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
            for (NSString *name in listArray) {
                //读取配置文件中的路径
                if ([dic.allKeys containsObject:name]) {
                    NSString *className = dic[name];
                    //通过容器暴露的方法注册API
                    BOOL success = [weakSelf.webloader registerHandlersWithClassName:className moduleName:name];
                    if (success == NO) {
                        configSuccess = 0;
                        msg = [NSString stringWithFormat:@"%@\n %@ API注册失败", msg, name];
                    }
                } else {
                    msg = [NSString stringWithFormat:@"%@\n %@ API类名未找到", msg, name];
                }
            }
        } else {
            configSuccess = 0;
            msg = @"jsApiList 参数错误";
        }
        
        NSDictionary *dic = [weakSelf responseDicWithCode:configSuccess Msg:msg result:nil];
        responseCallback(dic);
    }];
}

- (void)dealloc {
    NSLog(@"<QHJSAuthApi>dealloc");
}

@end



