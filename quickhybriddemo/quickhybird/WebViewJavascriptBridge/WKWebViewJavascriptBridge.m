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


- (void)registerHandlersWithAccess:(NSString *)className handlerName:(NSString *)handlerName {
    NSMutableDictionary *accessDic = _base.modulesAuthorityDic;
    
    
    NSMutableDictionary *classDic =  accessDic[className];
    if (!classDic) {
        classDic = [NSMutableDictionary dictionary];
    }
    // 默认权限配置
    
    if ([self checkDefaultAccessSetting:className handlerName:handlerName]) {
        [classDic setObject:@"1" forKey:handlerName];
    }
    accessDic[className] = classDic;
    _base.modulesAuthorityDic = accessDic;
}

/*
 根据 access.json 文件判断权限
 */
- (BOOL)checkDefaultAccessSetting:(NSString *)moduleName
                      handlerName:(NSString *)handlerName {
    return YES;
//    NSString *accessJson = @"{ \"moduleNames\":[\"ui\",\"page\",\"event\",\"navigator\"],\"handlers\":[\"getQHjsVersion\",\"getAppVersion\"] }";
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"access" ofType:@"json"];
//    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
//    if (data) {
//        accessJson = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    }
    
//    NSError *error = nil;
//    data = [accessJson dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:&error];
    NSDictionary *dic = @{
                          @"moduleNames" : @[
                                    @"ui",@"page",@"event",@"navigator"
                                  ],
                          @"handlers" : @[
                                    @"getQHjsVersion",@"getAppVersion"
                                  ]
                          };
    NSArray *moduleNames = dic[@"moduleNames"];
    NSArray *hanlders = dic[@"handlers"];
    for(NSString *mName in moduleNames) {
        if([mName isEqualToString:moduleName]) {
            return YES;
        }
    }
    for(NSString *hName in hanlders){
        if([hName isEqualToString:handlerName]) {
            return YES;
        }
    }
    
//    if (error) {
//        return NO;
//    } else {
//       
//    }
    return NO;
}

- (void)reset {
    [_base reset];
}

- (void)setWebViewDelegate:(QHBaseWebLoader<WKNavigationDelegate> *)webViewDelegate {
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
}


/* WKWebView Specific Internals
 ******************************/

- (void) _setupInstance:(WKWebView*)webView {
    _webView = webView;
    // QHJS V3.0 代理不再走bridge
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

- (void)excuteMessage:(NSString *)message
{
    
    // 转换成NSURL为nil
    NSString *msgUTF8 = [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *msgURL = [NSURL URLWithString:msgUTF8];
    if (!msgURL) { return; }
    if (![msgURL.scheme isEqualToString:@"QuickHybridJSBridge"]) { return; }
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
//    EJSDataRcoredUtil *util = [EJSDataRcoredUtil sharedRecordUtil];
//    [util writeToDataRecordWith:moduleName and:handlerName];
    
//    NSString *excuteMsg = [NSString stringWithFormat:@"[{\"%@\":\"%@\", \"%@\":\"%@\", \"%@\":%@}]", @"handlerName", handlerName, @"callbackId", callbackId, @"data", data];
//    [_base excuteMsg:excuteMsg moduleName:host];
}

// URI解码
- (NSString *)URLDecodedString:(NSString*)stringURL
{
    return (__bridge NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                        (CFStringRef)stringURL,
                                                                                        CFSTR(""), 
                                                                                        kCFStringEncodingUTF8); 
}


- (BOOL)registerHandlersWithClassName:(NSString *)className
                           moduleName:(NSString *)moduleName
{
    BOOL registerSuccess = YES;
    if ([className length] && [moduleName length]) {
        QHJSRegisterBaseClass *bsRegister = [[NSClassFromString(className) alloc] init];
        if (bsRegister && [bsRegister respondsToSelector:@selector(registerHandlers)]) {
            bsRegister.moduleName = moduleName;
            bsRegister.webloader = (QHBaseWebLoader *)_webViewDelegate;
            [bsRegister registerHandlers];
            [_base.modulesDic setObject:bsRegister forKey:moduleName];
        } else {
            registerSuccess = NO;
            NSLog(@"Api模块注册失败,ClassName:%@, moduleName:%@", className, moduleName);
        }
    } else {
        registerSuccess = NO;
    }
    return registerSuccess;
}

- (void)registerQHJSFrameAPI {
    // 注册ui api
    [self registerHandlersWithClassName:@"QHJSPageApi" moduleName:@"page"];
    [self registerHandlersWithClassName:@"QHJSRuntimeApi" moduleName:@"runtime"];
    [self registerHandlersWithClassName:@"QHJSDeviceApi" moduleName:@"device"];
    [self registerHandlersWithClassName:@"QHJSAuthApi" moduleName:@"auth"];
    [self registerHandlersWithClassName:@"QHJSUiApi" moduleName:@"ui"];
}

- (void)handleErrorWithCode:(NSInteger)errorCode
                   errorUrl:(NSString *)errorUrl
           errorDescription:(NSString *)errorDescription
{
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

- (WVJBResponseCallback)getCacheCallbackWithModuleName:(NSString *)moduleName
                                           handlerName:(NSString *)handlerName
{
    QHJSRegisterBaseClass *bs = [_base.modulesDic objectForKey:moduleName];
    WVJBResponseCallback callback = [bs cachedCallback:handlerName];
    return callback;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"WKWebViewJavascriptBridge"]) {
        [self excuteMessage:message.body];
    }
}

#pragma mark - WKWebViewDelegate
/*
 - (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
 {
 if (webView != _webView) { return; }
 
 __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
 if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
 [strongDelegate webView:webView didFinishNavigation:navigation];
 }
 }
 
 - (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
 {
 if (webView != _webView) { return; }
 
 __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
 if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didReceiveAuthenticationChallenge:completionHandler:)]) {
 [strongDelegate webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
 }
 }
 
 - (void)webView:(WKWebView *)webView
 decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
 decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
 if (webView != _webView) { return; }
 NSURL *url = navigationAction.request.URL;
 __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
 
 if ([_base isCorrectProcotocolScheme:url]) {
 if ([_base isBridgeLoadedURL:url]) {
 //            [_base injectJavascriptFile];
 } else if ([_base isQueueMessageURL:url]) {
 [self WKFlushMessageQueue];
 } else {
 [_base logUnkownMessage:url];
 }
 decisionHandler(WKNavigationActionPolicyCancel);
 }
 
 if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
 [_webViewDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
 } else {
 decisionHandler(WKNavigationActionPolicyAllow);
 }
 }
 
 - (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
 if (webView != _webView) { return; }
 
 __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
 if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
 [strongDelegate webView:webView didStartProvisionalNavigation:navigation];
 }
 }
 
 
 - (void)webView:(WKWebView *)webView
 didFailNavigation:(WKNavigation *)navigation
 withError:(NSError *)error {
 if (webView != _webView) { return; }
 
 __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
 if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailNavigation:withError:)]) {
 [strongDelegate webView:webView didFailNavigation:navigation withError:error];
 }
 }
 
 - (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
 if (webView != _webView) { return; }
 
 __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
 if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)]) {
 [strongDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
 }
 }
 */


@end
#endif
