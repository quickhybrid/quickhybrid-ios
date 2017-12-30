//
//  EJSPageApi.m
//  Pods
//
//  Created by HuangXJ on 2017/6/12.
//
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
}
@end
