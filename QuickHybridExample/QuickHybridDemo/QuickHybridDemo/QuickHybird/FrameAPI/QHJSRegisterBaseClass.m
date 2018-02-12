//
//  JSRegisterBaseClass.m
//  QuickHybirdJSBridgeDemo
//
//  Created by 管浩 on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//

#import "QHJSRegisterBaseClass.h"
#import "QHJSBaseWebLoader.h"

@interface QHJSRegisterBaseClass ()
/** API的实例字典，存取API的实例对象 */
@property (nonatomic, strong) NSMutableDictionary *handlesDic;
@end

@implementation QHJSRegisterBaseClass

- (NSMutableDictionary *)handlesDic {
    if (!_handlesDic) {
        _handlesDic = [NSMutableDictionary dictionary];
    }
    return _handlesDic;
}

#pragma mark --- 注册api的方法

- (void)registerHandlers {
    // 子类重写改方法实现自定义API注册
}

#pragma mark - handler存取方法

- (void)registerHandlerName:(NSString *)handleName handler:(WVJBHandler)handler {
    [self.handlesDic setObject:handler forKey:handleName];
}

- (WVJBHandler)handler:(NSString *)handlerName {
    return [self.handlesDic objectForKey:handlerName];
}

/**
 统一回调参数字典拼装
 
 @param code 1、0
 @param msg msg
 @param data result
 @return 封装好的字典
 */
- (NSDictionary *)responseDicWithCode:(NSInteger)code Msg:(NSString *)msg result:(id)data {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@(code) forKey:@"code"];
    
    if (msg == nil) {
        msg = @"";
    }
    [dic setObject:msg forKey:@"msg"];
    
    if (data) {
        [dic setObject:data forKey:@"result"];
    }
    return dic;
}

@end
