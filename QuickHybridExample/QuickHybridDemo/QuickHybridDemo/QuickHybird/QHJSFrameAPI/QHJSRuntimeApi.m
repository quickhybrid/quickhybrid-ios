//
//  QHJSUiApi.m
//  quickhybriddemo
//
//  Created by 戴荔春 on 2017/12/31.
//  Copyright © 2017年 quickhybrid. All rights reserved.
//

#import "QHJSRuntimeApi.h"
#import "QHJSInfo.h"
#import <WebKit/WebKit.h>
#import "QHJSLocationUtil.h"
#import "TQLocationConverter.h"

@interface QHJSRuntimeApi ()
@property (nonatomic, strong) QHJSLocationUtil *locationUtil;
@end

@implementation QHJSRuntimeApi

- (void)registerHandlers {
    __weak typeof(self) weakSelf = self;
    
    //打开第三方app
    [self registerHandlerName:@"launchApp" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSString *param = data[@"data"];
        NSString *scheme = data[@"scheme"];
        NSString *host = data[@"host"];
        //如果scheme为空，直接返回失败
        if (scheme.length == 0) {
            NSDictionary *responData = @{@"code" : @0 , @"msg" : @"Scheme不能为空"};
            responseCallback(responData);
        } else {
            NSString *appURL;
            if (![scheme hasSuffix:@"://"]) {
                appURL = [[NSString alloc] initWithFormat:@"%@://", scheme];
            } else {
                appURL = scheme;
            }
            if (host.length > 0) {
                appURL = [appURL stringByAppendingString:host];
            }
            if (param.length > 0) {
                appURL = [appURL stringByAppendingFormat:@"?data=%@", param];
            }
            NSURL *url = [NSURL URLWithString:appURL];
            
            NSMutableDictionary *responData = [NSMutableDictionary dictionary];
            [responData setValue:@1 forKey:@"code"];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                        if (success) {
                            [responData setObject:@"打开应用成功" forKey:@"msg"];
                        } else {
                            [responData setObject:@"打开应用失败" forKey:@"msg"];
                        }
                        responseCallback(responData);
                    }];
                } else {
                    BOOL success = [[UIApplication sharedApplication] openURL:url];
                    if (success) {
                        [responData setObject:@"打开应用成功" forKey:@"msg"];
                    } else {
                        [responData setObject:@"打开应用失败" forKey:@"msg"];
                    }
                    responseCallback(responData);
                }
            } else {
                [responData setObject:@"不能打开应用" forKey:@"msg"];
                responseCallback(responData);
            }
        }
        
    }];
    
    [self registerHandlerName:@"getAppVersion" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSDictionary *dic = [weakSelf responseDicWithCode:1 Msg:@"" result:@{@"version":appVersion}];
        responseCallback(dic);
    }];
    
    [self registerHandlerName:@"getQuickVersion" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *ejsVersion = [QHJSInfo getQHJSVersion];
        NSDictionary *dic = [weakSelf responseDicWithCode:1 Msg:@"" result:@{@"version":ejsVersion}];
        responseCallback(dic);
    }];
    
    //清除缓存
    [self registerHandlerName:@"clearCache" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (@available(iOS 9.0, *)) {
            NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
            NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
            [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
                NSDictionary *dic = [weakSelf responseDicWithCode:1 Msg:@"" result:@"clearCache finish"];
                responseCallback(dic);
            }];
        } else {
            NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
            NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
            
            //iOS8.0 webView cache的存放路径
            NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit", libraryDir];
            NSString *webKitFolderInCaches = [NSString stringWithFormat:@"%@/Caches/%@/WebKit", libraryDir, bundleId];
            
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:&error];
            [[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:nil];
            
            NSDictionary *dic = [weakSelf responseDicWithCode:1 Msg:@"" result:@"clearCache finish"];
            responseCallback(dic);
        }
    }];
    
    //获取地理位置
    [self registerHandlerName:@"getGeolocation" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSInteger isShowDetail = [data[@"isShowDetail"] integerValue];
        
        if (!weakSelf.locationUtil) {
            QHJSLocationUtil *locationUtil = [[QHJSLocationUtil alloc] init];
            weakSelf.locationUtil = locationUtil;
        }
        [weakSelf.locationUtil startUpdateLocation:^(CLLocation *location, NSString *errorStr) {
            if (errorStr) {
                NSDictionary *errorDic = [weakSelf responseDicWithCode:0 Msg:errorStr result:nil];
                responseCallback(errorDic);
            } else {
                CLLocationCoordinate2D standardLocation = [TQLocationConverter transformFromWGSToGCJ:location.coordinate];
                
                NSString *longitude = [NSString stringWithFormat:@"%f", standardLocation.longitude];
                NSString *latitude = [NSString stringWithFormat:@"%f", standardLocation.latitude];
                //设置返回字典中的经纬度
                NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
                [resultDic setObject:longitude forKey:@"longitude"];
                [resultDic setObject:latitude forKey:@"latitude"];
                
                if (isShowDetail == 1) {
                    [QHJSLocationUtil getBaiduLocationInfoInLocation:standardLocation complete:^(id response, NSError *error) {
                        if (error) {
                            //只返回经纬度
                            NSDictionary *backDic = [weakSelf responseDicWithCode:1 Msg:@"" result:resultDic];
                            responseCallback(backDic);
                        } else {
                            [resultDic setObject:response forKey:@"addressComponent"];
                            NSDictionary *backDic = [weakSelf responseDicWithCode:1 Msg:@"" result:resultDic];
                            responseCallback(backDic);
                        }
                    }];
                } else {
                    //只返回经纬度
                    NSDictionary *backDic = [weakSelf responseDicWithCode:1 Msg:@"" result:resultDic];
                    responseCallback(backDic);
                }
            }
            
        }];
        
    }];
    
    //复制到剪切板
    [self registerHandlerName:@"clipboard" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *text = [data objectForKey:@"text"];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = text;
    }];
    
    [self registerHandlerName:@"openUrl" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *url = [data objectForKey:@"url"];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication ] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
                    
                }];
            } else {
                [[UIApplication sharedApplication ] openURL:[NSURL URLWithString:url]];
            }
        }
    }];
}

- (void)dealloc {
    NSLog(@"<QHJSRuntimeApi>dealloc");
}

@end



