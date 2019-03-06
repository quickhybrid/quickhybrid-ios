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
    
    //设置标题
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
    
    //设置多个分栏标题
    [self registerHandlerName:@"setMultiTitle" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSArray *titles = [data objectForKey:@"titles"];
        QHJSNaviSegmentView *segView = [[QHJSNaviSegmentView alloc] initWithTitleItems:titles];
        segView.titleClickAction = ^(NSInteger which) {
            NSDictionary *dic = [weakSelf responseDicWithCode:1 Msg:@"" result:@{@"which":@(which)}];
            responseCallback(dic);
        };
        weakSelf.webloader.navigationItem.titleView = segView;
    }];
    
    //显示导航栏
    [self registerHandlerName:@"show" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf.webloader.navigationController setNavigationBarHidden:NO animated:YES];
    }];
    
    //隐藏导航栏
    [self registerHandlerName:@"hide" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf.webloader.navigationController setNavigationBarHidden:YES animated:YES];
    }];
    
    //显示状态栏
    [self registerHandlerName:@"showStatusBar" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf.webloader changeStatusBarHiddenState:NO];
    }];
    
    //隐藏状态栏
    [self registerHandlerName:@"hideStatusBar" handler:^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf.webloader changeStatusBarHiddenState:YES];
    }];
    
    //隐藏返回按钮
    [self registerHandlerName:@"hideBackBtn" handler:^(id data, WVJBResponseCallback responseCallback) {
        weakSelf.webloader.backBarButton = nil;
        weakSelf.webloader.navigationItem.leftBarButtonItem = nil;
    }];
    
    //拦截系统侧滑返回
    [self registerHandlerName:@"hookSysBack" handler:^(id data, WVJBResponseCallback responseCallback) {        
        //先阻止侧边返回事件
        weakSelf.webloader.interactivePopGestureRecognizerEnabled = NO;
        //保存回调
        [weakSelf saveObjectInCacheDic:responseCallback forKey:@"hookSysBack"];
    }];
    
    //拦截导航栏返回按钮
    [self registerHandlerName:@"hookBackBtn" handler:^(id data, WVJBResponseCallback responseCallback) {
        //先阻止侧边返回事件
        weakSelf.webloader.shouldPop = NO;
        //保存回调
        [weakSelf saveObjectInCacheDic:responseCallback forKey:@"hookBackBtn"];
    }];
    
    //设置导航栏右上角按钮
    [self registerHandlerName:@"setRightBtn" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSInteger isShow = [[data objectForKey:@"isShow"] integerValue];
        NSInteger which = [[data objectForKey:@"which"] integerValue];
        if (isShow == 1) {
            NSString *title = [data objectForKey:@"text"];
            NSString *imageUrl = [data objectForKey:@"imageUrl"];
            //调用设置方法
            if (title.length > 0) {
                if (which == 0) {
                    [weakSelf.webloader setRightNaviItemAtIndex:1 andTitle:title OrImageUrl:nil];
                } else {
                    [weakSelf.webloader setRightNaviItemAtIndex:2 andTitle:title OrImageUrl:nil];
                }
            } else if (imageUrl.length > 0) {
                if (which == 0) {
                    [weakSelf.webloader setRightNaviItemAtIndex:1 andTitle:nil OrImageUrl:imageUrl];
                } else {
                    [weakSelf.webloader setRightNaviItemAtIndex:2 andTitle:nil OrImageUrl:imageUrl];
                }
            }
            
            //缓存回调
            if (which == 0) {
                [weakSelf saveObjectInCacheDic:responseCallback forKey:@"setRightBtn1"];
            } else {
                [weakSelf saveObjectInCacheDic:responseCallback forKey:@"setRightBtn2"];
            }

        } else {
            //隐藏相应的按钮
            if (which == 0) {
                [weakSelf.webloader hideRightNaviItemAtIndex:1];
                [weakSelf removeObjectForKeyInCacheDic:@"setRightBtn1"];
            } else {
                [weakSelf.webloader hideRightNaviItemAtIndex:2];
                [weakSelf removeObjectForKeyInCacheDic:@"setRightBtn2"];
            }
        }
    }];
    
    //设置导航栏左上角按钮
    [self registerHandlerName:@"setLeftBtn" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSInteger isShow = [[data objectForKey:@"isShow"] integerValue];
        NSString *title = [data objectForKey:@"text"];
        NSString *imageUrl = [data objectForKey:@"imageUrl"];
        NSInteger isShowArrow = [[data objectForKey:@"isShowArrow"] integerValue];
        NSString *direction = [data objectForKey:@"direction"];
        if (isShow == 1) {
            //显示按钮，优先设置图片
            if (title.length > 0) {
                [weakSelf.webloader setLeftNaviItemWithTitle:title OrImageUrl:nil AndIsShowBackArrow:isShowArrow];
            } else if (imageUrl.length > 0) {
                [weakSelf.webloader setLeftNaviItemWithTitle:nil OrImageUrl:imageUrl AndIsShowBackArrow:isShowArrow];
            }
            [weakSelf saveObjectInCacheDic:responseCallback forKey:@"setLeftBtn"];
        } else {
            //隐藏按钮
            [weakSelf.webloader hideLeftNaviItem];
            [weakSelf removeObjectForKeyInCacheDic:@"setLeftBtn"];
        }
    }];
}

- (void)dealloc {
    NSLog(@"<QHJSNavigatorApi>dealloc");
}

@end
