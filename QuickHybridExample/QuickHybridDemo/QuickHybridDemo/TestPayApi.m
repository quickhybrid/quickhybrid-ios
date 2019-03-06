//
//  TestPayApi
//
//  Created by guanhao on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//


#import "TestPayApi.h"

@implementation TestPayApi

- (void)registerHandlers {
    __weak typeof(self) weakSelf = self;
    
    [self registerHandlerName:@"testPay" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *dic = [weakSelf responseDicWithCode:1 Msg:@"success" result:@"testPay"];
        responseCallback(dic);
    }];
}

- (void)dealloc {
    NSLog(@"<TestPayApi>dealloc");
}

@end
