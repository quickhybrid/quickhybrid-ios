//
//  TestPayApi
//
//  Created by 管浩 on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//


#import "TestPayApi.h"

@implementation TestPayApi

- (void)registerHandlers {
    [self registerHandlerName:@"testPay" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *dic = [self responseDicWithCode:1 Msg:@"success" result:@"testPay"];
        responseCallback(dic);
    }];
}
@end
