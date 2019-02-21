//
//  QHJSNavigatorApi.m
//  QuickHybridDemo
//
//  Created by guanhao on 2018/2/15.
//  Copyright © 2018年 com.quickhybrid. All rights reserved.
//

#import "QHJSNavigatorApi.h"
#import "QHJSNaviTitleView.h"
#import "QHJSNaviSegmentView.h"

@implementation QHJSNavigatorApi

- (void)registerHandlers {
    
    __weak typeof(self) weakSelf = self;
    
    [self registerHandlerName:@"setTitle" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *title = [data objectForKey:@"title"];
        NSString *subTitle = [data objectForKey:@"subTitle"];
        NSInteger clickable = [[data objectForKey:@"clickable"] integerValue];
        NSString *direction = [data objectForKey:@"direction"];
        QHJSNaviTitleView *titleView = [[QHJSNaviTitleView alloc] initWithMainTitle:title subTitle:subTitle clickable:clickable direction:direction];
        titleView.clickAction = ^(BOOL click) {
            NSDictionary *dic = [weakSelf responseDicWithCode:1 Msg:@"" result:nil];
            responseCallback(dic);
        };
        weakSelf.webloader.navigationItem.titleView = titleView;
    }];
    
    [self registerHandlerName:@"setMultiTitle" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSArray *titles = [data objectForKey:@"titles"];
        QHJSNaviSegmentView *segView = [[QHJSNaviSegmentView alloc] initWithTitleItems:titles];
        segView.titleClickAction = ^(NSInteger which) {
            NSDictionary *dic = [weakSelf responseDicWithCode:1 Msg:@"" result:@{@"which":@(which)}];
            responseCallback(dic);
        };
        weakSelf.webloader.navigationItem.titleView = segView;
    }];
    
//    [self registerHandlerName:@"show" handler:^(id data, WVJBResponseCallback responseCallback) {
//        [weakSelf.webloader.navigationController setNavigationBarHidden:NO animated:YES];
//    }];
//    
//    [self registerHandlerName:@"hide" handler:^(id data, WVJBResponseCallback responseCallback) {
//        [weakSelf.webloader.navigationController setNavigationBarHidden:YES animated:YES];
//    }];
//
//    [self registerHandlerName:@"showStatusBar" handler:^(id data, WVJBResponseCallback responseCallback) {
//        [weakSelf.webloader changeStatusBarHiddenState:NO];
//    }];
//
//    [self registerHandlerName:@"hideStatusBar" handler:^(id data, WVJBResponseCallback responseCallback) {
//        [weakSelf.webloader changeStatusBarHiddenState:YES];
//    }];
    
}

- (void)dealloc {
    NSLog(@"<QHJSNavigatorApi>dealloc");
}

@end
