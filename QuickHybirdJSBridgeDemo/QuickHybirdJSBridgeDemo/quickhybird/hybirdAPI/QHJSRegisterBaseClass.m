//
//  JSRegisterBaseClass.m
//  QuickHybirdJSBridgeDemo
//
//  Created by 管浩 on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//

#import "QHJSRegisterBaseClass.h"
#import "QHBaseWebLoader.h"

@interface QHJSRegisterBaseClass ()
@property (nonatomic, strong) NSMutableDictionary *handlesDic;
@property (nonatomic, strong) NSMutableDictionary *longCallbacksDic;
@end

@implementation QHJSRegisterBaseClass
#pragma mark - 注册api的统一方法
- (void)registerHandlers {
    // 子类重写改方法实现自定义API注册
}

#pragma mark - handler存取
- (void)registerHandlerName:(NSString *)handleName
                    handler:(WVJBHandler)handler {
    [self.webloader registerAccessWithClassName:self.moduleName methodName:handleName];
    [self.handlesDic setObject:handler forKey:handleName];
}

- (WVJBHandler)handler:(NSString *)handlerName {
    return [self.handlesDic objectForKey:handlerName];
}

#pragma mark - 长期回调存取
- (void)cacheCallback:(WVJBResponseCallback)callback
          handlerName:(NSString *)handlerName {
    if (callback && [handlerName length]) {
        [self.longCallbacksDic setObject:callback forKey:handlerName];
    }
}

- (void)removeCacheCallback:(NSString *)handlerName {
    [self.longCallbacksDic removeObjectForKey:handlerName];
}

- (WVJBResponseCallback)cachedCallback:(NSString *)handerName {
    if ([handerName length]) {
        return [self.longCallbacksDic objectForKey:handerName];
    } else {
        return nil;
    }
}

#pragma mark - 统一回调参数字典拼装
- (NSDictionary *)responseDicWithCode:(NSInteger)code
                                  Msg:(NSString *)msg
                                 result:(id)data {
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

#pragma setters and getters
- (NSMutableDictionary *)handlesDic {
    if (!_handlesDic) {
        _handlesDic = [NSMutableDictionary dictionary];
    }
    return _handlesDic;
}

- (NSMutableDictionary *)longCallbacksDic {
    if (!_longCallbacksDic) {
        _longCallbacksDic = [NSMutableDictionary dictionary];
    }
    return _longCallbacksDic;
}
@end
