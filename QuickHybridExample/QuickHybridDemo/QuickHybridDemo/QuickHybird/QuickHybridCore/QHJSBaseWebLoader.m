//
//  QHJSBaseWebLoader.m
//  QuickHybirdJSBridgeDemo
//
//  Created by guanhao on 2017/12/30.
//  Copyright © 2017年 com.gh. All rights reserved.
//

#import "QHJSBaseWebLoader.h"
#import "WKWebViewJavascriptBridge.h"

static NSString *KVOContext;

@interface QHJSBaseWebLoader () <WKUIDelegate, WKNavigationDelegate>
/** JSBridge */
@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;
/** 页面加载进度条 */
@property (nonatomic, weak) UIProgressView *progressView;
/** 加载进度条的高度约束 */
@property (nonatomic, strong) NSLayoutConstraint *progressH;

/** 导航栏左上角页面返回按钮 */
@property (nonatomic, strong) UIBarButtonItem *closeButtonItem;

/** 导航栏右上角按钮，1在右，2在左 */
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem1;
/** 导航栏右上角按钮，1在右，2在左 */
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem2;

/** 导航栏左上角按钮 */
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@end

@implementation QHJSBaseWebLoader

#pragma mark --- 生命周期

+ (void)initialize {
    //改变User-Agent
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //获取默认UA
        NSString *defaultUA = [[UIWebView new] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        
        //设置UA格式，和h5约定
        NSString *version = [QHJSInfo getQHJSVersion];
        NSString *customerUA = [defaultUA stringByAppendingString:[NSString stringWithFormat:@" QuickHybridJs/%@", version]];
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":customerUA}];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建WKWebView
    [self createWKWebView];
    
    // 注册KVO
    [self.wv addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:&KVOContext];
    [self.wv addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:&KVOContext];
    
    // 注册框架API
    [self.bridge registerFrameAPI];
    
    // 加载H5页面
    [self loadHTML];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //导航栏参数
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if ([[[self.params valueForKey:@"pageStyle"] stringValue] isEqualToString:@"-1"]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

/**
 创建WKWebView
 */
- (void)createWKWebView {
    // 创建进度条
    UIProgressView *progressView = [[UIProgressView alloc] init];
    progressView.progressTintColor = [UIColor lightGrayColor];
    [self.view addSubview:progressView];
    self.progressView = progressView;
    progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:progressView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
                                [NSLayoutConstraint constraintWithItem:progressView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
                                [NSLayoutConstraint constraintWithItem:progressView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]
                                ]];
    NSLayoutConstraint *progressH = [NSLayoutConstraint constraintWithItem:progressView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:1.5];
    self.progressH = progressH;
    [progressView addConstraint:self.progressH];
    
    // 创建webView容器
    WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userContentVC = [[WKUserContentController alloc] init];
    webConfig.userContentController = userContentVC;
    WKWebView *wk = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webConfig];
    [self.view addSubview:wk];
    self.wv = wk;
    self.wv.navigationDelegate = self;
    self.wv.UIDelegate = self;
    self.wv.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 设置约束
    [self.view addConstraints:@[// left
                                [NSLayoutConstraint constraintWithItem:self.wv attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
                                // bottom
                                [NSLayoutConstraint constraintWithItem:self.wv attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0],
                                // right
                                [NSLayoutConstraint constraintWithItem:self.wv attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0],
                                // top
                                [NSLayoutConstraint constraintWithItem:self.wv attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:progressView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0],
                                ]];
    
    //jsBridge
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.wv];
    [self.bridge setWebViewDelegate:self];
    
    [self.wv.configuration.userContentController addScriptMessageHandler:self.bridge name:@"WKWebViewJavascriptBridge"];
}

/**
 加载地址
 */
- (void)loadHTML {
    NSString *url = [[self.params valueForKey:@"pageUrl"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    if ([url hasPrefix:@"http"]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.wv loadRequest:request];
    } else {
        // 加载本地页面，iOS 8不支持
        if (@available(iOS 9.0, *)) {
            //本地路径的html页面路径
            NSURL *pathUrl = [NSURL URLWithString:url];
            NSURL *bundleUrl = [[NSBundle mainBundle] bundleURL];
            [self.wv loadFileURL:pathUrl allowingReadAccessToURL:bundleUrl];
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"发生错误" message:@"本地页面的方式不支持iOS9以下" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

#pragma mark --- KVO

/**
 KVO监听的相应方法
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    // 判断是否是本类注册的KVO
    if (context == &KVOContext) {
        // 设置title
        if ([keyPath isEqualToString:@"title"]) {
            NSString *title = change[@"new"];
            self.navigationItem.title = title;
        }
        // 设置进度
        if ([keyPath isEqualToString:@"estimatedProgress"]) {
            NSNumber *progress = change[@"new"];
            self.progressView.progress = progress.floatValue;
            if (progress.floatValue == 1.0) {
                self.progressH.constant = 0;
                __weak typeof(self) weakSelf = self;
                [UIView animateWithDuration:0.25 animations:^{
                    [weakSelf.view layoutIfNeeded];
                }];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark --- WKNavigationDelegate

//这个代理方法不实现也能正常跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([navigationAction.request.URL.absoluteString isEqualToString:@"about:blank"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        //支持 a 标签 target = ‘_blank’ ;
        if (navigationAction.targetFrame == nil) {
            [self openWindow:navigationAction];
        } else if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
            [self setCloseBarBtn];
        }
        
        NSURL *url = navigationAction.request.URL;
        //扫一扫支持iOS下载应用安装
        if ([url.absoluteString hasPrefix:@"itms-services://"] || [url.absoluteString hasPrefix:@"https://itunes.apple.com/cn/app"]) {
            [[UIApplication sharedApplication] openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
        } else {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    }
}

/**
 特殊跳转
 */
- (void)openWindow:(WKNavigationAction *)navigationAction {
    self.progressView.progress = 0;
    self.progressH.constant = 1;
    [self.wv loadRequest:navigationAction.request];
}

- (void)setCloseBarBtn {
    //初始化返回按钮
    self.closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:(UIBarButtonItemStylePlain) target:self action:@selector(closeBtnAction:)];
    
    if (self.leftBarButtonItem) {
        return;
    }
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItems = @[];
    if (self.backBarButton) {
        self.navigationItem.leftBarButtonItems = @[self.backBarButton, self.closeButtonItem];
    }
}

- (void)closeBtnAction:(id)sender {
    if ([self.bridge containObjectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"hookBackBtn"]) {
        WVJBResponseCallback backCallback = (WVJBResponseCallback)[self.bridge objectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"hookBackBtn"];
        NSDictionary *dic = @{@"code":@1, @"msg":@"Native pop Action"};
        backCallback(dic);
    } else {
        NSString *jsStr = [NSString stringWithFormat:@"closeAction()"];
        [self.wv evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if (error) {
                [self backAction];
            }
        }];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}

//重定向
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [self setCloseBarBtn];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    // ErroeCode
    // -1001 请求超时   -1009 似乎已断开与互联网的连接
    if (error.code == -1009) {
        NSLog(@"似乎已断开与互联网的连接");
        return;
    }
    if (error.code == -1001) {
        NSLog(@"请求超时");
        return;
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    //页面加载异常
    NSString *url = [self.params objectForKey:@"pageUrl"];
    //反馈页面加载错误
    [self.bridge handleErrorWithCode:0 errorUrl:url errorDescription:error.localizedDescription];
}

// https校验
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
}

#pragma mark --- WKUIDelegate
//WebVeiw关闭
- (void)webViewDidClose:(WKWebView *)webView {
    
}

//显示一个JavaScript警告面板
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

//显示一个JavaScript确认面板
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    [alertController addAction:action1];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    [alertController addAction:action2];
    [self presentViewController:alertController animated:YES completion:nil];
}

//显示一个JavaScript文本输入面板
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark --- QHJSPageApi

//刷新方法
- (void)reloadWKWebview {
    [self.wv reload];
}

#pragma mark --- QHJSNavigatorApi

//重写拦截系统侧滑返回的方法
- (BOOL)hookInteractivePopGestureRecognizerEnabled {
    if ([self.bridge containObjectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"hookSysBack"]) {
        WVJBResponseCallback sysBackCallback = (WVJBResponseCallback)[self.bridge objectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"hookSysBack"];
        NSDictionary *dic = @{@"code":@1, @"msg":@"Native pop Action"};
        sysBackCallback(dic);
    }
    return self.interactivePopGestureRecognizerEnabled;
}

//重写导航栏左侧返回按钮方法
- (void)backAction {
    if (self.shouldPop) {
        [super backAction];
    } else {
        if ([self.bridge containObjectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"hookBackBtn"]) {
            WVJBResponseCallback backCallback = (WVJBResponseCallback)[self.bridge objectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"hookBackBtn"];
            NSDictionary *dic = @{@"code":@1, @"msg":@"Native pop Action"};
            backCallback(dic);
        }
    }
}

/**
 设置导航栏按钮的方法
 */
- (void)setRightNaviItemAtIndex:(NSInteger)index andTitle:(NSString *)title OrImageUrl:(NSString *)imageUrl {
    if (index == 1) {
        if (title) {
            self.rightBarButtonItem1 = [[UIBarButtonItem alloc] initWithTitle:title style:(UIBarButtonItemStylePlain) target:self action:@selector(clickRightNaviItem1:)];
        } else {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            if (imageData) {
                self.rightBarButtonItem1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithData:imageData] style:(UIBarButtonItemStylePlain) target:self action:@selector(clickRightNaviItem1:)];
            } else {
                self.rightBarButtonItem1 = [[UIBarButtonItem alloc] initWithTitle:@"图片" style:(UIBarButtonItemStylePlain) target:self action:@selector(clickRightNaviItem1:)];
            }
        }
    } else {
        if (title) {
            self.rightBarButtonItem2 = [[UIBarButtonItem alloc] initWithTitle:title style:(UIBarButtonItemStylePlain) target:self action:@selector(clickRightNaviItem2:)];
        } else {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            if (imageData) {
                self.rightBarButtonItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithData:imageData] style:(UIBarButtonItemStylePlain) target:self action:@selector(clickRightNaviItem2:)];
            } else {
                self.rightBarButtonItem2 = [[UIBarButtonItem alloc] initWithTitle:@"图片" style:(UIBarButtonItemStylePlain) target:self action:@selector(clickRightNaviItem2:)];
            }
        }
    }
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItems = @[];
    
    if (self.rightBarButtonItem1) {
        if (self.rightBarButtonItem2) {
            self.navigationItem.rightBarButtonItems = @[self.rightBarButtonItem1, self.rightBarButtonItem2];
        } else {
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem1;
        }
    } else {
        if (self.rightBarButtonItem2) {
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem2;
        }
    }
}

- (void)clickRightNaviItem1:(id)sender {
    if ([self.bridge containObjectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"setRightBtn1"]) {
        WVJBResponseCallback callback = (WVJBResponseCallback)[self.bridge objectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"setRightBtn1"];
        NSDictionary *dic = @{@"code":@1, @"msg":@"rightBtn1Action"};
        callback(dic);
    }
}

- (void)clickRightNaviItem2:(id)sender {
    if ([self.bridge containObjectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"setRightBtn2"]) {
        WVJBResponseCallback callback = (WVJBResponseCallback)[self.bridge objectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"setRightBtn2"];
        NSDictionary *dic = @{@"code":@1, @"msg":@"rightBtn2Action"};
        callback(dic);
    }
}

/**
 隐藏导航栏右上角按钮的方法
 
 @param index 位置索引，1在右，2在左
 */
- (void)hideRightNaviItemAtIndex:(NSInteger)index {
    if (index == 1) {
        self.rightBarButtonItem1 = nil;
    } else {
        self.rightBarButtonItem2 = nil;
    }
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItems = @[];
    
    if (self.rightBarButtonItem1) {
        if (self.rightBarButtonItem2) {
            self.navigationItem.rightBarButtonItems = @[self.rightBarButtonItem1, self.rightBarButtonItem2];
        } else {
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem1;
        }
    } else {
        if (self.rightBarButtonItem2) {
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem2;
        }
    }
}

//设置导航栏左侧按钮
- (void)setLeftNaviItemWithTitle:(NSString *)title OrImageUrl:(NSString *)imageUrl AndIsShowBackArrow:(NSInteger)isShowArrow {
    if (title) {
        self.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:(UIBarButtonItemStylePlain) target:self action:@selector(clickLeftNaviItem:)];
    } else {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        if (imageData) {
            self.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithData:imageData] style:(UIBarButtonItemStylePlain) target:self action:@selector(clickLeftNaviItem:)];
        } else {
            self.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"图片" style:(UIBarButtonItemStylePlain) target:self action:@selector(clickLeftNaviItem:)];
        }
    }
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItems = @[];
    if (self.backBarButton) {
        if (self.leftBarButtonItem) {
            self.navigationItem.leftBarButtonItems = @[self.backBarButton, self.leftBarButtonItem];
        } else {
            self.navigationItem.leftBarButtonItem = self.backBarButton;
        }
    } else {
        if (self.leftBarButtonItem) {
            self.navigationItem.leftBarButtonItem = self.leftBarButtonItem;
        }
    }
}

- (void)clickLeftNaviItem:(id)sender {
    if ([self.bridge containObjectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"setLeftBtn"]) {
        WVJBResponseCallback callback = (WVJBResponseCallback)[self.bridge objectForKeyInCacheDicWithModuleName:@"navigator" KeyName:@"setLeftBtn"];
        NSDictionary *dic = @{@"code":@1, @"msg":@"leftBtnAction"};
        callback(dic);
    }
}

//隐藏导航栏左上角自定义按钮的方法
- (void)hideLeftNaviItem {
    self.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.leftBarButtonItems = @[];
    
    if (self.backBarButton) {
        if (self.closeButtonItem) {
            self.navigationItem.leftBarButtonItems = @[self.backBarButton, self.closeButtonItem];
        } else {
            self.navigationItem.leftBarButtonItem = self.backBarButton;
        }
    } else {
        if (self.closeButtonItem) {
            self.navigationItem.leftBarButtonItem = self.closeButtonItem;
        }
    }
}

#pragma mark --- MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark --- QHJSAuthApi

//注册自定义API的方法
- (BOOL)registerHandlersWithClassName:(NSString *)className moduleName:(NSString *)moduleName {
    return [self.bridge registerHandlersWithClassName:className moduleName:moduleName];
}

- (void)dealloc {
    [self.wv.configuration.userContentController removeScriptMessageHandlerForName:@"WKWebViewJavascriptBridge"];
    [self.wv.configuration.userContentController removeAllUserScripts];
    [self.wv removeObserver:self forKeyPath:@"title" context:&KVOContext];
    [self.wv removeObserver:self forKeyPath:@"estimatedProgress" context:&KVOContext];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"<QHJSBaseWebLoader>dealloc");
}

@end
