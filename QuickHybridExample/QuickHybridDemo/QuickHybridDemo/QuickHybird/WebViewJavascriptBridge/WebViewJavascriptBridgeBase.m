//
//  WebViewJavascriptBridgeBase.m
//
//  Created by @LokiMeyburg on 10/15/14.
//  Copyright (c) 2014 @LokiMeyburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WebViewJavascriptBridgeBase.h"
#import "QHJSRegisterBaseClass.h"

@implementation WebViewJavascriptBridgeBase {
    __weak id _webViewDelegate;
    long _uniqueId;
}

static bool logging = false;
static int logMaxLength = 500;

+ (void)enableLogging { logging = true; }
+ (void)setLogMaxLength:(int)length { logMaxLength = length;}

-(id)init {
    if (self = [super init]) {
        self.messageHandlers = [NSMutableDictionary dictionary];
        self.startupMessageQueue = [NSMutableArray array];
        self.responseCallbacks = [NSMutableDictionary dictionary];
        _uniqueId = 0;
    }
    return self;
}

- (void)dealloc {
    self.startupMessageQueue = nil;
    self.responseCallbacks = nil;
    self.messageHandlers = nil;
}

- (void)reset {
    self.startupMessageQueue = [NSMutableArray array];
    self.responseCallbacks = [NSMutableDictionary dictionary];
    _uniqueId = 0;
}

- (void)sendData:(id)data responseCallback:(WVJBResponseCallback)responseCallback handlerName:(NSString*)handlerName {
    NSMutableDictionary* message = [NSMutableDictionary dictionary];
    
    if (data) {
        message[@"data"] = data;
    }
    
    if (responseCallback) {
        NSString* callbackId = [NSString stringWithFormat:@"objc_cb_%ld", ++_uniqueId];
        self.responseCallbacks[callbackId] = [responseCallback copy];
        message[@"callbackId"] = callbackId;
    }
    
    if (handlerName) {
        message[@"handlerName"] = handlerName;
    }
    [self _queueMessage:message];
}

- (void)flushMessageQueue:(NSString *)messageQueueString{
    if (messageQueueString == nil || messageQueueString.length == 0) {
        NSLog(@"WebViewJavascriptBridge: WARNING: ObjC got nil while fetching the message queue JSON from webview. This can happen if the WebViewJavascriptBridge JS is not currently present in the webview, e.g if the webview just loaded a new page.");
        return;
    }

    id messages = [self _deserializeMessageJSON:messageQueueString];
    for (WVJBMessage* message in messages) {
        if (![message isKindOfClass:[WVJBMessage class]]) {
            NSLog(@"WebViewJavascriptBridge: WARNING: Invalid %@ received: %@", [message class], message);
            continue;
        }
        [self _log:@"RCVD" json:message];
        
        NSString* responseId = message[@"responseId"];
        if (responseId) {
            WVJBResponseCallback responseCallback = _responseCallbacks[responseId];
            responseCallback(message[@"responseData"]);
            [self.responseCallbacks removeObjectForKey:responseId];
        } else {
            WVJBResponseCallback responseCallback = NULL;
            NSString* callbackId = message[@"callbackId"];
            if (callbackId) {
                responseCallback = ^(id responseData) {
                    if (responseData == nil) {
                        responseData = [NSNull null];
                    }
                    
                    WVJBMessage* msg = @{ @"responseId":callbackId, @"responseData":responseData };
                    [self _queueMessage:msg];
                };
            } else {
                responseCallback = ^(id ignoreResponseData) {
                    // Do nothing
                };
            }
            
            WVJBHandler handler = self.messageHandlers[message[@"handlerName"]];
            
            if (!handler) {
                NSLog(@"WVJBNoHandlerException, No handler for message from JS: %@", message);
#ifdef DEBUG
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"QHJS 错误信息提示" message:[NSString stringWithFormat:@"No handler for message from JS: %@", message] delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                [alert show];
#endif
                continue;
            }
            
            handler(message[@"data"], responseCallback);
        }
    }
}

//- (void)injectJavascriptFile {
//    NSString *js = WebViewJavascriptBridge_js();
//    [self _evaluateJavascript:js];
//    if (self.startupMessageQueue) {
//        NSArray* queue = self.startupMessageQueue;
//        self.startupMessageQueue = nil;
//        for (id queuedMessage in queue) {
//            [self _dispatchMessage:queuedMessage];
//        }
//    }
//}

//- (BOOL)isCorrectProcotocolScheme:(NSURL*)url {
//    if([[url scheme] isEqualToString:kCustomProtocolScheme]){
//        return YES;
//    } else {
//        return NO;
//    }
//}

//-(BOOL)isQueueMessageURL:(NSURL*)url {
//    if([[url host] isEqualToString:kQueueHasMessage] || [[url host] isEqualToString:kCustomQueueHasMessage]){
//        return YES;
//    } else {
//        return NO;
//    }
//}

//-(BOOL)isBridgeLoadedURL:(NSURL*)url {
//    return ([[url scheme] isEqualToString:kCustomProtocolScheme] && [[url host] isEqualToString:kBridgeLoaded]);
//}

//-(void)logUnkownMessage:(NSURL*)url {
//    NSLog(@"WebViewJavascriptBridge: WARNING: Received unknown WebViewJavascriptBridge command %@://%@", kCustomProtocolScheme, [url path]);
//}

//-(NSString *)webViewJavascriptCheckCommand {
//    return @"typeof WebViewJavascriptBridge == \'object\';";
//}

-(NSString *)webViewJavascriptFetchQueyCommand {
    return @"JSBridge._fetchQueue();";
}

- (void)disableJavscriptAlertBoxSafetyTimeout {
    [self sendData:nil responseCallback:nil handlerName:@"_disableJavascriptAlertBoxSafetyTimeout"];
}

// Private
// -------------------------------------------

- (void) _evaluateJavascript:(NSString *)javascriptCommand {
    [self.delegate _evaluateJavascript:javascriptCommand];
}

- (void)_queueMessage:(WVJBMessage*)message {
//    if (self.startupMessageQueue) {
//        [self.startupMessageQueue addObject:message];
//    } else {
//        [self _dispatchMessage:message];
//    }
    [self _dispatchMessage:message];
}

- (void)_dispatchMessage:(WVJBMessage*)message {
    NSString *messageJSON = [self _serializeMessage:message pretty:NO];
    [self _log:@"SEND" json:messageJSON];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    
    NSString* javascriptCommand = [NSString stringWithFormat:@"JSBridge._handleMessageFromNative('%@');", messageJSON];
    if ([[NSThread currentThread] isMainThread]) {
        [self _evaluateJavascript:javascriptCommand];

    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self _evaluateJavascript:javascriptCommand];
        });
    }
}

- (NSString *)_serializeMessage:(id)message pretty:(BOOL)pretty{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:(NSJSONWritingOptions)(pretty ? NSJSONWritingPrettyPrinted : 0) error:nil] encoding:NSUTF8StringEncoding];
}

- (NSArray*)_deserializeMessageJSON:(NSString *)messageJSON {
    return [NSJSONSerialization JSONObjectWithData:[messageJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
}

- (void)_log:(NSString *)action json:(id)json {
    if (!logging) { return; }
    if (![json isKindOfClass:[NSString class]]) {
        json = [self _serializeMessage:json pretty:YES];
    }
    if ([json length] > logMaxLength) {
        NSLog(@"WVJB %@: %@ [...]", action, [json substringToIndex:logMaxLength]);
    } else {
        NSLog(@"WVJB %@: %@", action, json);
    }
}

#pragma mark --- QHJS

- (NSArray *)deserializeMessageJSON:(NSString *)messageJSON {
    return [self _deserializeMessageJSON:messageJSON];
}

- (void)excuteMsg:(NSDictionary *)msgDic {
    // 输出内容
    NSLog(@"RCVC:%@", msgDic);
    
    NSString *moduleName = msgDic[@"moduleName"];
    NSString *callbackId = msgDic[@"callbackId"];
    
    //判断模块是否存在
    QHJSRegisterBaseClass *bs = [self.modulesDic objectForKey:moduleName];
    if (moduleName) {
        if (bs == nil) {
            //模块未注册
            NSLog(@"调用模块未注册");
            if (callbackId) {
                [self callbackWithId:callbackId code:@0 msg:@"调用模块未注册"];
            } else {
                NSLog(@"调用模块未注册，并且回调不存在");
            }
            return;
        }
    } else {
        NSLog(@"JS未传moduleName参数");
    }
    
    WVJBResponseCallback responseCallback = NULL;
    if (callbackId) {
        responseCallback = ^(id responseData) {
            if (responseData == nil) {
                responseData = [NSNull null];
            }
            WVJBMessage* msg = @{@"responseId":callbackId, @"responseData":responseData};
            [self _queueMessage:msg];
        };
    } else {
        responseCallback = ^(id ignoreResponseData) {
            // Do nothing
        };
    }
    NSString *handlerName = msgDic[@"handlerName"];
    if (!handlerName) {
        if (callbackId) {
            [self callbackWithId:callbackId code:@0 msg:@"API名字参数未传"];
        } else {
            NSLog(@"API名字参数未传，并且回调不存在");
        }
        return;
    }
    WVJBHandler handler = [bs handler:handlerName];
    if (!handler) {
        if (callbackId) {
            [self callbackWithId:callbackId code:@0 msg:@"API未注册"];
        } else {
            NSLog(@"API未注册，并且回调不存在");
        }
        return;
    }
    
    handler(msgDic[@"data"], responseCallback);
    return;
}

- (void)callbackWithId:(NSString *)callbackId code:(id)code msg:(NSString *)msg {
    if (callbackId) {
        NSMutableDictionary *responseData = [NSMutableDictionary dictionary];
        if (code) {
            [responseData setObject:code forKey:@"code"];
        }
        
        if (msg) {
            [responseData setObject:msg forKey:@"msg"];
        }
        
        WVJBMessage *errorMsg = @{ @"responseId":callbackId, @"responseData":responseData };
        [self _queueMessage:errorMsg];
    }
}

- (NSMutableDictionary *)modulesDic {
    if (_modulesDic == nil) {
        _modulesDic = [NSMutableDictionary dictionary];
    }
    return _modulesDic;
}

@end
