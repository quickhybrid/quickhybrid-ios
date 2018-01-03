//
//  QHJSPageApi.m
//  QuickHybirdJSBridgeDemo
//
//  Created by 管浩 on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//

#import "QHJSPageApi.h"
#import "QHBaseWebLoader.h"

@implementation QHJSPageApi

- (void)registerHandlers {
    [self registerHandlerName:@"open" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        QHBaseWebLoader *bs = [[QHBaseWebLoader alloc] init];
        bs.params = [NSMutableDictionary dictionaryWithDictionary:data];
        bs.pageCallback = ^(NSString *resultData) {
            if (resultData) {
                NSDictionary *dic = [self responseDicWithCode:1 Msg:@"" result:@{@"resultData":resultData}];
                responseCallback(dic);
            }
        };
        
        if (self.webloader.navigationController) {
            [self.webloader.navigationController pushViewController:bs animated:YES];
        } else if (self.webloader.tabBarController && self.webloader.tabBarController.navigationController) {
            [self.webloader.tabBarController.navigationController pushViewController:bs animated:YES];
        } else {
            NSLog(@"navigationController不存在，无法push控制器");
        }
    }];
    
    [self registerHandlerName:@"openLocal" handler:^(id data, WVJBResponseCallback responseCallback) {
        // className
        // isOpenExist
        // data: 只有一层键值对
        NSInteger isOpenExist = [[data objectForKey:@"isOpenExist"] integerValue];
        NSString *className = [data objectForKey:@"className"];
        
        if (isOpenExist == 0 ) {
            QHBaseViewController *bsVC = [NSClassFromString(className) new];
            if (bsVC == nil) {
                NSDictionary *dic = [self responseDicWithCode:0 Msg:@"原生页面不存在" result:nil];
                responseCallback(dic);
                return;
            }
            id externParams = [data objectForKey:@"data"];
            if (externParams) {
                bsVC.params = [NSMutableDictionary dictionaryWithDictionary:externParams];
            }
            
            bsVC.pageCallback = ^(id resultData) {
                if (resultData) {
                    NSDictionary *dic = [self responseDicWithCode:1 Msg:@"" result:@{@"resultData":resultData}];
                    responseCallback(dic);
                }
            };
            
            if (self.webloader.navigationController) {
                [self.webloader.navigationController pushViewController:bsVC animated:YES];
            } else if (self.webloader.tabBarController && self.webloader.tabBarController.navigationController) {
                [self.webloader.tabBarController.navigationController pushViewController:bsVC animated:YES];
            } else {
                NSLog(@"navigationController不存在，无法push控制器");
            }
        }
        
        if (isOpenExist == 1) {
            for (UIViewController *vc in self.webloader.navigationController.viewControllers) {
                if ([vc isKindOfClass:NSClassFromString(className)]) {
                    [self.webloader.navigationController popToViewController:vc animated:YES];
                }
            }
        }
        
    }];
    
    [self registerHandlerName:@"close" handler:^(id data, WVJBResponseCallback responseCallback) {
        // 回调的值
        NSString *resuldData = data[@"resultData"];
        // pop的页面数目
        NSNumber *popPageNumber = [data objectForKey:@"popPageNumber"];
        NSInteger number = 1;
        
        if (popPageNumber) {
            number = [popPageNumber integerValue];
        }
        
        if (number == 1) {
            if (self.webloader.pageCallback) {
                self.webloader.pageCallback(resuldData);
            }
            [self.webloader backAction];
        } else {
            NSArray *vcArray = self.webloader.navigationController.viewControllers;
            // 超过上限主动修改，变为最大可推出的页面数量
            if (number >= vcArray.count) {
                number = vcArray.count - 1;
            }
            if (number > 0 && number < vcArray.count) {
                NSInteger pageIndex = vcArray.count - number - 1;
                QHBaseViewController *popVC = [vcArray objectAtIndex:pageIndex];
                // 获取popVC对应的页面回调
                QHBaseViewController *callbackVC = [vcArray objectAtIndex:pageIndex + 1];
                if (callbackVC.pageCallback) {
                    callbackVC.pageCallback(resuldData);
                }
                [self.webloader.navigationController popToViewController:popVC animated:YES];
            } else {
                // pop越界
                NSLog(@"close api 返回多个页面时，返回的页面数超过了nav中控制器的个数");
            }
        }
        
    }];
    
    [self registerHandlerName:@"reload" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self.webloader reloadWKWebview];
    }];

}
@end
