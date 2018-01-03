//
//  QHJSAuthApi.m
//  quickhybriddemo
//
//  Created by 戴荔春 on 2017/12/31.
//  Copyright © 2017年 quickhybrid. All rights reserved.
//

#import "QHJSAuthApi.h"
#import "QHBaseWebLoader.h"

@implementation QHJSAuthApi

- (void)registerHandlers {
    [self registerHandlerName:@"getToken" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *token = @"testtoken";
        if (token.length == 0) { token = @""; }
        NSDictionary *resultDic = @{@"access_token":token};
        NSDictionary *responData = @{@"result":resultDic, @"code":@1, @"msg":@"token"};
        responseCallback(responData);
    }];
    
    [self registerHandlerName:@"config" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSInteger configSuccess = 1;
        NSString *msg = @"";
        NSArray *listArray = [data objectForKey:@"jsApiList"];
        if ([listArray isKindOfClass:[NSArray class]]) {
            
            NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"qhjsmodules" ofType:@"plist"];
            NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
            
            for (NSString *name  in listArray) {
                // 读取配置文件中的路径
                if ([dic.allKeys containsObject:name]) {
                    NSString *className = dic[name];
                    BOOL success = [self.webloader registerHandlersWithClassName:className moduleName:name];
                    if (success == NO) {
                        configSuccess = 0;
                        msg = @"api注册失败";
                    }
                }
                
            }
        } else {
            configSuccess = 0;
            msg = @"jsApiList 参数错误";
        }
        
        
        NSDictionary *dic = [self responseDicWithCode:configSuccess Msg:msg result:nil];
        responseCallback(dic);
    }];
}
@end



