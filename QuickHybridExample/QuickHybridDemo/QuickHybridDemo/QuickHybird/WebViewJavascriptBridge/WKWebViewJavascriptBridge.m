//
//  WKWebViewJavascriptBridge.m
//
//  Created by @LokiMeyburg on 10/15/14.
//  Copyright (c) 2014 @LokiMeyburg. All rights reserved.
//


#import "WKWebViewJavascriptBridge.h"
#import "QHJSRegisterBaseClass.h"

#if defined(supportsWKWebKit)

@interface WKWebViewJavascriptBridge ()

@end

@implementation WKWebViewJavascriptBridge {
    __weak WKWebView* _webView;
    __weak id<WKNavigationDelegate> _webViewDelegate;
    long _uniqueId;
    WebViewJavascriptBridgeBase *_base;
}

/* API
 *****/

+ (void)enableLogging { [WebViewJavascriptBridgeBase enableLogging]; }

+ (instancetype)bridgeForWebView:(WKWebView*)webView {
    WKWebViewJavascriptBridge* bridge = [[self alloc] init];
    [bridge _setupInstance:webView];
    [bridge reset];
    return bridge;
}

- (void)send:(id)data {
    [self send:data responseCallback:nil];
}

- (void)send:(id)data responseCallback:(WVJBResponseCallback)responseCallback {
    [_base sendData:data responseCallback:responseCallback handlerName:nil];
}

- (void)callHandler:(NSString *)handlerName {
    [self callHandler:handlerName data:nil responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self callHandler:handlerName data:data responseCallback:nil];
}

- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback {
    [_base sendData:data responseCallback:responseCallback handlerName:handlerName];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    _base.messageHandlers[handlerName] = [handler copy];
}

- (void)reset {
    [_base reset];
}

- (void)setWebViewDelegate:(id<WKNavigationDelegate>)webViewDelegate {
    _webViewDelegate = webViewDelegate;
}

- (void)disableJavscriptAlertBoxSafetyTimeout {
    [_base disableJavscriptAlertBoxSafetyTimeout];
}

/* Internals
 ***********/

- (void)dealloc {
    _base = nil;
    _webView = nil;
    _webViewDelegate = nil;
    _webView.navigationDelegate = nil;
    
    NSLog(@"<WKWebViewJavascriptBridge>dealloc");
}


/* WKWebView Specific Internals
 ******************************/

- (void) _setupInstance:(WKWebView*)webView {
    _webView = webView;
//    _webView.navigationDelegate = self;
    _base = [[WebViewJavascriptBridgeBase alloc] init];
    _base.delegate = self;
}


- (void)WKFlushMessageQueue {
    [_webView evaluateJavaScript:[_base webViewJavascriptFetchQueyCommand] completionHandler:^(NSString* result, NSError* error) {
        if (error != nil) {
            NSLog(@"WebViewJavascriptBridge: WARNING: Error when trying to fetch data from WKWebView: %@", error);
        }
        [_base flushMessageQueue:result];
    }];
}

- (NSString*) _evaluateJavascript:(NSString*)javascriptCommand
{
    [_webView evaluateJavaScript:javascriptCommand completionHandler:nil];
    return NULL;
}

#pragma mark --- QHJS

//注册框架已有的API
- (void)registerFrameAPI {
    [self registerHandlersWithClassName:@"QHJSPageApi" moduleName:@"page"];
    [self registerHandlersWithClassName:@"QHJSUIApi" moduleName:@"ui"];
    [self registerHandlersWithClassName:@"QHJSNavigatorApi" moduleName:@"navigator"];
    [self registerHandlersWithClassName:@"QHJSRuntimeApi" moduleName:@"runtime"];
    [self registerHandlersWithClassName:@"QHJSDeviceApi" moduleName:@"device"];
    [self registerHandlersWithClassName:@"QHJSAuthApi" moduleName:@"auth"];
}

- (BOOL)registerHandlersWithClassName:(NSString *)className moduleName:(NSString *)moduleName {
    BOOL registerSuccess = YES;
    if ([className length] && [moduleName length]) {
        QHJSRegisterBaseClass *bsRegister = [[NSClassFromString(className) alloc] init];
        if (bsRegister && [bsRegister respondsToSelector:@selector(registerHandlers)]) {
            bsRegister.moduleName = moduleName;
            bsRegister.webloader = (QHJSBaseWebLoader *)_webViewDelegate;
            [bsRegister registerHandlers];
            [_base.modulesDic setObject:bsRegister forKey:moduleName];
        } else {
            registerSuccess = NO;
            NSLog(@"Api模块注册失败, ClassName:%@, moduleName:%@", className, moduleName);
        }
    } else {
        registerSuccess = NO;
    }
    return registerSuccess;
}

//获取页面内临时缓存的数据或方法
- (id)objectForKeyInCacheDicWithModuleName:(NSString *)moduleName KeyName:(NSString *)keyName {
    if ([_base.modulesDic.allKeys containsObject:moduleName]) {
        QHJSRegisterBaseClass *bs = [_base.modulesDic objectForKey:moduleName];
        id object = [bs objectForKeyInCacheDic:keyName];
        if (object) {
            return object;
        }
    }
    return nil;
}

- (BOOL)containObjectForKeyInCacheDicWithModuleName:(NSString *)moduleName KeyName:(NSString *)keyName {
    if ([_base.modulesDic.allKeys containsObject:moduleName]) {
        QHJSRegisterBaseClass *bs = [_base.modulesDic objectForKey:moduleName];
        if ([bs containObjectForKeyInCacheDic:keyName]) {
            return YES;
        }
    }
    return NO;
}

//删除页面内临时缓存的数据或方法
- (void)removeObjectForKeyInCacheDicWithModuleName:(NSString *)moduleName KeyName:(NSString *)keyName {
    QHJSRegisterBaseClass *bs = [_base.modulesDic objectForKey:moduleName];
    [bs removeObjectForKeyInCacheDic:keyName];
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"WKWebViewJavascriptBridge"]) {
        //解析数据
        [self excuteMessage:message.body];
    }
}

/**
 解析数据等逻辑
 */
- (void)excuteMessage:(NSString *)message {
//    NSString *msgUTF8 = [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSString *msgUTF8 = [message stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *msgURL = [NSURL URLWithString:message];
    if (!msgURL) {
        return;
    }
    if (![msgURL.scheme isEqualToString:@"QuickHybridJSBridge"]) {
        return;
    }
    // 解析参数
    NSString *moduleName = msgURL.host;
    NSString *handlerName = msgURL.path.lastPathComponent;
    NSString *callbackId = msgURL.port.stringValue;
    NSString *dataStr = [msgURL.query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *data = [self URLDecodedString:dataStr];
    id dataObj = [_base deserializeMessageJSON:data];
    
    NSMutableDictionary *msgDic = [NSMutableDictionary dictionary];
    if (handlerName) {
        [msgDic setObject:handlerName forKey:@"handlerName"];
    }
    if (callbackId) {
        [msgDic setObject:callbackId forKey:@"callbackId"];
    }
    if (dataObj) {
        [msgDic setObject:dataObj forKey:@"data"];
    }
    if (moduleName) {
        [msgDic setObject:moduleName forKey:@"moduleName"];
    }
    [_base excuteMsg:msgDic];
}

// URI解码
- (NSString *)URLDecodedString:(NSString*)stringURL {
    return (__bridge NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)stringURL, CFSTR(""), kCFStringEncodingUTF8);
}

- (void)handleErrorWithCode:(NSInteger)errorCode errorUrl:(NSString *)errorUrl errorDescription:(NSString *)errorDescription {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:@(errorCode) forKey:@"errorCode"];
    if (errorUrl) {
        [paramDic setObject:errorUrl forKey:@"errorUrl"];
    }
    if (errorDescription) {
        [paramDic setObject:errorDescription forKey:@"errorDescription"];
    }
    [_base sendData:paramDic responseCallback:nil handlerName:@"handleError"];
}

@end
#endif
