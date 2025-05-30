//
//  LZWebViewController.m
//  Pods
//
//  Created by Dear.Q on 2017/4/7.
//
//

#import "LZWebViewController.h"
#import <objc/runtime.h>
#import <AVKit/AVKit.h>
#import <LZDependencyToolkit/LZDependencyToolkit.h>
#import "LZMarqueeLabel.h"

/**
 @author Lilei
 
 @brief 弱代理
 */
@interface LZWeakScriptMessageDelegate : NSObject<WKScriptMessageHandler, WKScriptMessageHandlerWithReply>

/** 代理 */
@property (nonatomic, weak) id<WKScriptMessageHandler> delegate;
/** 保存 JS 回调 Block */
@property (nonatomic, copy) void (^completionHanderBlock)(WKScriptMessage *_Nullable message, void (^_Nullable replyCallback)(id  _Nullable reply, NSString * _Nullable errorMessage));

/**
 @author Lilei
 
 @brief 实例
 
 @param scriptDelegate 代理
 @return LZWeakScriptMessageDelegate
 */
- (instancetype)initWithDelegate:(id)scriptDelegate;

@end

@implementation LZWeakScriptMessageDelegate

// MARK: - Public
- (instancetype)initWithDelegate:(id)scriptDelegate {
    if (self = [super init]) {
        self.delegate = scriptDelegate;
    }
    return self;
}

// MARK: - Delegate
// MARK: <WKScriptMessageHandler>
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if (self.completionHanderBlock) {
        self.completionHanderBlock(message, nil);
    }
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
                 replyHandler:(void (^)(id _Nullable reply, NSString *_Nullable errorMessage))replyHandler {
    if (self.completionHanderBlock) {
        self.completionHanderBlock(message, replyHandler);
    }
}

@end

NSString * const LZWebEmptyURL = @"about:blank";
static NSString * const LZWebTitle = @"title";
//static NSString * const LZWebProgress = @"estimatedProgress";
static NSString * const LZCanGoBack = @"canGoBack";
static NSString * const LZURLSchemeTel = @"tel";
static NSString * const LZURLSchemeSms = @"sms";
static NSString * const LZURLSchemeMail = @"mailto";

@interface LZWebViewController ()
<WKNavigationDelegate, WKUIDelegate>

/** WebView */
@property (nonatomic, strong) WKWebView *webView;
/** 进度条 */
@property (nonatomic, strong) UIProgressView *progressView;
/** 是否是子页面 */
@property (nonatomic, assign, getter = isSubWeb) BOOL subWeb;
/** 附加视图 */
@property (nonatomic, weak) UIView *attachView;
/** 标题视图 */
@property (nonatomic, weak) LZMarqueeLabel *titlelabel;
/** ScriptMessage 容器 */
@property (nonatomic, strong) NSMutableDictionary *scriptMessageContainer;
/** 用于判断是否是同一个 webpage */
@property (nonatomic, strong) WKNavigation *webNavigation;

@end

@implementation LZWebViewController

// MARK: - Lazy Loading
- (WKWebView *)webView {
    if (nil == _webView) {
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.allowsInlineMediaPlayback = self.allowsInlineMediaPlayback;
        if (@available(iOS 10.0, *)) {
            config.mediaTypesRequiringUserActionForPlayback = self.mediaPlaybackRequiresUserAction ? WKAudiovisualMediaTypeAll : WKAudiovisualMediaTypeNone;
        } else if (@available(iOS 9, *)) {
            config.requiresUserActionForMediaPlayback = self.mediaPlaybackRequiresUserAction;
        } else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
            config.mediaPlaybackRequiresUserAction = self.mediaPlaybackRequiresUserAction;
#endif
        }
        config.allowsAirPlayForMediaPlayback = YES;
        [config.preferences setValue:@(self.accessFromFileURLs) forKey:@"allowFileAccessFromFileURLs"];
        if (@available(iOS 10.0, *)) {
            [config setValue:@(self.accessFromFileURLs) forKey:@"allowUniversalAccessFromFileURLs"];
        }
        if (@available(iOS 15.4, *)) {
//            config.preferences.elementFullscreenEnabled = YES;
        }
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    }
    return _webView;
}

- (NSMutableDictionary *)scriptMessageContainer {
    if (nil == _scriptMessageContainer) _scriptMessageContainer = [NSMutableDictionary dictionary];
    return _scriptMessageContainer;
}

- (NSMutableArray *)allowSchemes {
    if (nil == _allowSchemes) {
        _allowSchemes = [NSMutableArray array];
    }
    if (0 == _allowSchemes.count) {
        
        [_allowSchemes addObjectsFromArray:@[LZURLSchemeTel, LZURLSchemeSms, LZURLSchemeMail]];
        NSArray *queriesSchemes = [NSBundle.mainBundle.infoDictionary objectForKey:@"LSApplicationQueriesSchemes"];
        if (queriesSchemes && queriesSchemes.count) {
            [_allowSchemes addObjectsFromArray:queriesSchemes];
        }
    }
    return _allowSchemes;
}

// MARK: - Initialization
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupDefaultValue];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self setupDefaultValue];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self registerObserver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.displayRefresh) {
        [self configRefreshControl];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect webFrame = self.view.bounds;
    CGRect attachFrame = self.attachView.frame;
    // 附件视图 Frame
    attachFrame.size.width = webFrame.size.width;
    attachFrame.origin.y = webFrame.size.height - attachFrame.size.height;
    self.attachView.frame = attachFrame;
    // Web 视图 Frame
    webFrame.size.height -= attachFrame.size.height;
    self.webView.frame = webFrame;
}

- (void)dealloc {
    NSLog(@"已经死去%s", __PRETTY_FUNCTION__);
    if (self.disappearToRefresh) {
        [self.webView reload];
    }
    if (self.closeCompletionCallback) {
        self.closeCompletionCallback();
    }
    
    self.webView.navigationDelegate = nil;
    self.webView.UIDelegate = nil;
    
    [self removeObserver];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"Web页面内存警告!:%@", NSStringFromClass([self class]));
    [self.webView stopLoading];
    @lzweakify(self);
    dispatch_after(0.25, dispatch_get_main_queue(), ^{
        @lzstrongify(self);
        [self.webView reload];
        [self reloadRequest];
    });
}

// MARK: - Setter
- (void)setURL:(NSURL *)URL {
    _URL = URL;
    
    [self reloadRequest];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    
    if (title && title.length) {
        if (@available(iOS 11, *)) {
            
            LZMarqueeLabel *titleView = [[LZMarqueeLabel alloc] init];
            titleView.marqueeLabelType = LZMarqueeLabelTypeLeft;
            NSDictionary *attributes = [self.navigationController.navigationBar titleTextAttributes];
            if (nil == attributes || 0 == attributes.count) {
                
                Class appearanceClass = [UINavigationController class];
                UINavigationBar *theme = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[appearanceClass]];
                if (@available(iOS 13, *)) {
                    attributes = theme.standardAppearance.titleTextAttributes;
                } else {
                    attributes = [theme titleTextAttributes];
                }
            }
            if (nil == attributes || 0 == attributes.count) {
                attributes = @{
                    NSForegroundColorAttributeName : LZColorWithHexString(@"#333333"),
                    NSFontAttributeName : LZQuickUnit.fontWeight(18, UIFontWeightSemibold),
                };
            }
            titleView.attributedText = [[NSAttributedString alloc] initWithString:title attributes:attributes];
            self.navigationItem.titleView = titleView;
        }
    }
}

// MARK: - Public
- (instancetype)initWithAttachView:(UIView *)view {
    if (self = [super init]) {
        
        [self.view addSubview:view];
        self.attachView = view;
    }
    return self;
}

- (void)reloadPage {
    if ([NSThread isMainThread]) {
        [self.webView reloadFromOrigin];
    } else {
        @lzweakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @lzstrongify(self);
            [self reloadPage];
        });
    }
}

- (void)reloadRequest {
    if ([NSThread isMainThread]) {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:self.URL];
        self.webNavigation = [self.webView loadRequest:request];
    } else {
        @lzweakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @lzstrongify(self);
            [self reloadRequest];
        });
    }
}

- (void)goback {
    
    WKBackForwardList *backForwardList = [self.webView backForwardList];
    NSMutableArray *backList = [NSMutableArray arrayWithArray:backForwardList.backList];
    [backList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(WKBackForwardListItem *backItem, NSUInteger idx, BOOL * _Nonnull stop) {
        for (NSString *urlStr in self.gobackIgnoreList) {
            if (NSNotFound != [backItem.URL.absoluteString rangeOfString:urlStr].location) {
                [backList removeObject:backItem];
            }
        }
    }];
    WKBackForwardListItem *backItem = [backList lastObject];
    if (nil != backItem) {
        
        [self.webView goToBackForwardListItem:backItem];
        if (self.gobackCallback) {
            self.gobackCallback(backItem);
        }
    } else {
        [self closeDidClick];
    }
}

- (void)JSInvokeNative:(NSString *)funcName
     completionHandler:(void (^)(id))completionHandler {
    [self JSInvokeNative1:funcName completionHandler:^(id _Nonnull message, void (^ _Nullable replyHandler)(id _Nullable, NSString * _Nullable)) {
        if (completionHandler) {
            completionHandler(message);
        }
    }];
}

- (void)JSInvokeNative1:(NSString *)funcName
      completionHandler:(void (^)(id _Nonnull, void (^ _Nullable)(id _Nullable, NSString * _Nullable)))completionHandler {
    [self javascriptInvokeNative:funcName completeHandler:completionHandler];
}

- (void)nativeInvokeJS:(NSString *)jsScript
     completionHandler:(void (^)(id, NSError *))completionHandler {
    NSAssert(nil != jsScript && jsScript.length, @"Java Script 不能为空");
    if (nil == jsScript || !jsScript.length) return;
    [self.webView evaluateJavaScript:jsScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        LZLog(@"Java Script<%@>: result:%@ error:%@", jsScript, result, error);
        if (completionHandler) {
            completionHandler(result, error);
        }
    }];
}

- (void)invokeUserScript:(NSString *)source
                 message:(NSString *)funcName
           injectionTime:(WKUserScriptInjectionTime)injectionTime
       completionHandler:(void (^)(id _Nonnull))completionHandler {
    [self invokeUserScript1:source message:funcName injectionTime:injectionTime completionHandler:^(id  _Nonnull message, void (^ _Nullable replyHandler)(id _Nullable, NSString * _Nullable)) {
        if (completionHandler) {
            completionHandler(message);
        }
    }];
}

- (void)invokeUserScript1:(NSString *)source
                  message:(NSString *)funcName
            injectionTime:(WKUserScriptInjectionTime)injectionTime
        completionHandler:(void (^)(id _Nonnull, void (^ _Nullable)(id _Nullable, NSString * _Nullable)))completionHandler {
    
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:source
                                                      injectionTime:injectionTime
                                                   forMainFrameOnly:YES];
    [self.webView.configuration.userContentController addUserScript:userScript];
    [self javascriptInvokeNative:funcName completeHandler:completionHandler];
}

- (BOOL)shouldAddNavItem {
    if (self.navigationController != nil) {
        if ([self isPush]) {
            return YES;
        } else if ([self isPresent]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (void)resetWebview {
    
    [self removeWebViewObserver];
    [self.webView removeFromSuperview];
    self.webView = nil;
    [self initConfig];
    [self registerWebViewObserver];
}

// MARK: - UI Action
- (void)goBackDidClick {
    if ([self canGoback]) {
        [self goback];
    } else {
        [self closeDidClick];
    }
}

- (void)closeDidClick {
    if (self.navigationController) {
        if ([self isPush]) {
            [self.navigationController popViewControllerAnimated:YES];
        } else  {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// MARK: - Private
- (void)setupDefaultValue {
    
    self.navBackTitle = @"返回";
    self.navBackIcon = nil;
    self.navCloseTitle = @"关闭";
    self.navCloseIcon = nil;
    self.navAutoAddClose = NO;
    
    self.showWebTitle = YES;
    
    self.displayProgress = YES;
    self.progressColor = [UIColor blueColor];
    self.progressTrackColor = [UIColor clearColor];
    
    self.displayRefresh = NO;
    
    self.displayEmptyPage = NO;
    self.emptyDataSetTitle = @"加载失败了~";
    self.emptyDataSetDetail = @"请稍后重试";
    
    self.disappearToRefresh = NO;
    
    self.allowsInlineMediaPlayback = NO;
    self.mediaPlaybackRequiresUserAction = NO;
    self.accessFromFileURLs = NO;
    
    self.rotationLandscape = NO;
    
    self.subWeb = NO;
}

- (void)initConfig {
    
    NSHTTPCookieStorage *HTTPCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [HTTPCookie setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.translatesAutoresizingMaskIntoConstraints = YES;
    self.webView.autoresizesSubviews = YES;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self configNavigation];
}

- (void)registerObserver {
    
    [self registerWebViewObserver];
    [self registerTargetObserver];
}

- (void)removeObserver {
    
    [self removeWebViewObserver];
    [self removeTargetObserver];
}

- (void)registerWebViewObserver {
    @try {
        [self.webView addObserver:self forKeyPath:LZWebTitle options:NSKeyValueObservingOptionNew context:NULL];
        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
        [self.webView addObserver:self forKeyPath:LZCanGoBack options:NSKeyValueObservingOptionNew context:NULL];
        if (@available(iOS 16, *)) {
            [self.webView addObserver:self forKeyPath:@"fullscreenState" options:NSKeyValueObservingOptionNew context:NULL];
        }
    } @catch (NSException *exception) {
    } @finally {
    }
    // 监听URL变化
    NSString *urlSource = @"window.addEventListener('popstate', () => { \
        var newURL = window.location.href; \
        webkit.messageHandlers.lz_urlChangeHandler.postMessage(newURL); \
    });";
    @lzweakify(self);
    [self invokeUserScript:urlSource message:@"lz_urlChangeHandler" injectionTime:WKUserScriptInjectionTimeAtDocumentStart completionHandler:^(id _Nonnull message) {
        @lzstrongify(self);
        if (self.urlChangeCallback) {
            self.urlChangeCallback(message);
        }
    }];
    // 监听DOM加载完成
    NSString *domSource = @"document.addEventListener('DOMContentLoaded', () => { \
        webkit.messageHandlers.lz_DOMLoaded.postMessage('ready'); \
    });";
    [self invokeUserScript:domSource message:@"lz_DOMLoaded" injectionTime:WKUserScriptInjectionTimeAtDocumentStart completionHandler:^(id _Nonnull message) {
        @lzstrongify(self);
        if (self.DOMLoadedCallback) {
            self.DOMLoadedCallback(message);
        }
    }];
    // 被动触发Router变化
    [self JSInvokeNative:@"routeChange" completionHandler:^(id _Nonnull message) {
        @lzstrongify(self);
        if (self.routerChangeCallback) {
            self.routerChangeCallback(message);
        }
    }];
}

- (void)removeWebViewObserver {
    @try {
        WKUserContentController *userCC = self.webView.configuration.userContentController;
        [self.scriptMessageContainer enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [userCC removeScriptMessageHandlerForName:key];
        }];
    } @catch (NSException *exception) {
        NSLog(@"移除 WebView Script 崩溃:%@", exception);
    } @finally {}
    @try {
        WKUserContentController *userCC = self.webView.configuration.userContentController;
        [userCC removeAllUserScripts];
        if (@available(iOS 14, *)) {
            [userCC removeAllScriptMessageHandlers];
        }
    } @catch (NSException *exception) {
        NSLog(@"移除 UserScript 崩溃:%@", exception);
    } @finally {}
    @try {
        if (YES == self.isViewLoaded) {
            [self.webView removeObserver:self forKeyPath:LZWebTitle];
        }
    } @catch (NSException *exception) {
        NSLog(@"移除 WebView %@ 通知崩溃:%@", LZWebTitle, exception);
    } @finally {}
    @try {
        if (YES == self.isViewLoaded) {
            [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
        }
    } @catch (NSException *exception) {
        NSLog(@"移除 WebView %@ 通知崩溃:%@", @"estimatedProgress", exception);
    } @finally {}
    @try {
        if (YES == self.isViewLoaded) {
            [self.webView removeObserver:self forKeyPath:LZCanGoBack];
        }
    } @catch (NSException *exception) {
        NSLog(@"移除 WebView %@ 通知崩溃:%@", LZCanGoBack, exception);
    } @finally {}
    @try {
        if (@available(iOS 16, *)) {
            [self.webView removeObserver:self forKeyPath:@"fullscreenState"];
        }
    } @catch (NSException *exception) {
        NSLog(@"移除 WebView %@ 通知崩溃:%@", @"fullscreenState", exception);
    } @finally {}
}

- (void)registerTargetObserver {
    @try {
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(beginFullScreen:)
         name:UIWindowDidBecomeVisibleNotification
         object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(endFullScreen:)
         name:UIWindowDidBecomeHiddenNotification
         object:nil];
    } @catch (NSException *exception) {
    } @finally {
    }
}

- (void)removeTargetObserver {
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    } @catch (NSException *exception) {
        NSLog(@"移除 WebView 通知崩溃:%@", exception);
    } @finally {}
}

- (void)configRefreshControl {
    @lzweakify(self);
    [self.webView.scrollView headerWithRefreshingBlock:^{
        @lzstrongify(self);
        [self reloadRequest];
    }];
}

- (void)configNavigation {
    if ([self shouldAddNavItem]) {
        
        UIBarButtonItem *back = [UIBarButtonItem itemWithTitle:self.navBackTitle
                                                   normalImage:self.navBackIcon
                                                highlightImage:self.navBackIcon
                                                  disableImage:self.navBackIcon
                                                        target:self
                                                        action:@selector(goBackDidClick)];
        self.navigationItem.leftBarButtonItems = @[back];
    }
}

- (void)correctNavigationButton {
    if ([self shouldAddNavItem]) {
        
        UIBarButtonItem *back = [UIBarButtonItem itemWithTitle:self.navBackTitle
                                                   normalImage:self.navBackIcon
                                                highlightImage:self.navBackIcon
                                                  disableImage:self.navBackIcon
                                                        target:self
                                                        action:@selector(goBackDidClick)];
        UIBarButtonItem *close = [UIBarButtonItem itemWithTitle:self.navCloseTitle
                                                    normalImage:self.navCloseIcon
                                                 highlightImage:self.navCloseIcon
                                                   disableImage:self.navCloseIcon
                                                         target:self
                                                         action:@selector(closeDidClick)];
        if (self.navAutoAddClose) {
            if ([self canGoback]) self.navigationItem.leftBarButtonItems = @[back, close];
            else self.navigationItem.leftBarButtonItems = @[back];
        } else {
            self.navigationItem.leftBarButtonItems = @[back, close];
        }
    }
}

- (BOOL)canGoback {
    return [self.webView canGoBack];
}

- (BOOL)isPush {
    return self.navigationController.topViewController == self && self.navigationController.viewControllers.count > 1;
}

- (BOOL)isPresent {
    return self.presentingViewController != nil;
}

- (void)stopRefresh {
    [self.webView.scrollView endHeaderRefresh];
}

- (void)javascriptInvokeNative:(NSString *)funcName
               completeHandler:(void (^ _Nullable)(id message, void (^ _Nullable replyCallback)( id _Nullable reply, NSString *_Nullable errorMessage)))completeHandler {
    NSAssert(nil != funcName && funcName.length, @"funcName 不能空");
    if (completeHandler) [self.scriptMessageContainer setObject:completeHandler forKey:funcName];
    // JS 调用 OC，添加处理脚本
    LZWeakScriptMessageDelegate *scriptMessageDelegate = [[LZWeakScriptMessageDelegate alloc] initWithDelegate:self];
    scriptMessageDelegate.completionHanderBlock = ^(WKScriptMessage * _Nullable message, void (^ _Nullable replyCallback)(id _Nullable, NSString * _Nullable)) {
        LZLog(@"MessageHandlerName<%@>: messageClass:%@ message:%@ replyCallback:%@", funcName, [message.body class], message.body, replyCallback);
        if (completeHandler) completeHandler(message.body, replyCallback);
    };
    
    if (@available(iOS 14.0, *)) {
        [self.webView.configuration.userContentController addScriptMessageHandlerWithReply:scriptMessageDelegate contentWorld:[WKContentWorld pageWorld] name:funcName];
    } else {
        [self.webView.configuration.userContentController addScriptMessageHandler:scriptMessageDelegate name:funcName];
    }
}

// MARK: - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:LZWebTitle] && object == self.webView) {
        if (self.showWebTitle) {
            if (NO == [self.title isValidString]) {
                self.title = self.webView.title;
            }
            if (NO == [self.title isEqualToString:self.webView.title]) {
                self.title = self.webView.title;
            }
        }
    } else if ([keyPath isEqual:@"estimatedProgress"] && object == self.webView) {
        LZLog(@"Web load progress:%f", self.webView.estimatedProgress);
        if (self.displayProgress) {
            if (nil == self.progressView) {
                
                CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1);
                self.progressView = [[UIProgressView alloc] initWithFrame:frame];
                self.progressView.trackTintColor = self.progressTrackColor;
                self.progressView.progressTintColor = self.progressColor;
                self.progressView.progressViewStyle = UIProgressViewStyleBar;
                [self.view addSubview:self.progressView];
            }
            [self.progressView setAlpha:1.0f];
            @lzweakify(self);
            [UIView animateWithDuration:0.25 animations:^{
                @lzstrongify(self);
                [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
            }];
            if (self.progressHandler) {
                self.progressHandler(self.webView.estimatedProgress);
            }
            if (self.webView.estimatedProgress >= 1.0f) {
                [UIView animateWithDuration:0.25 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    @lzstrongify(self);
                    [self.progressView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    @lzstrongify(self);
                    [self.progressView setProgress:0.0f animated:NO];
                }];
            }
        }
    } else if ([keyPath isEqualToString:LZCanGoBack] && object == self.webView) {
        [self correctNavigationButton];
    } else if ([keyPath isEqualToString:@"fullscreenState"]) {
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)beginFullScreen:(NSNotification *)notifi {
    if (YES == self.rotationLandscape) {
        
        UIWindow *window = (UIWindow *)notifi.object;
        if ([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")]
            || [window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")]) {
            return;
        }
        [self setupNeedRotation:YES];
        [self forceChangeOrientation:UIInterfaceOrientationLandscapeRight];
    }
}

- (void)endFullScreen:(NSNotification *)notifi {
    if (YES == self.rotationLandscape) {
        if (@available(iOS 12, *)) {
            
            UIWindow *window = (UIWindow *)notifi.object;
            if (window) {
                
                UIViewController *rootViewController = window.rootViewController;
                NSArray<__kindof UIViewController *> *viewVCArray = rootViewController.childViewControllers;
                if ([viewVCArray.firstObject isKindOfClass:[AVPlayerViewController class]]) {
                    
                    SEL selector = @selector(setStatusBarHidden:withAnimation:);
                    if ([[UIApplication sharedApplication] respondsToSelector:selector]) {
                        
                        NSMethodSignature *signature = [UIApplication instanceMethodSignatureForSelector:selector];
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                        [invocation setSelector:selector];
                        [invocation setTarget:[UIApplication sharedApplication]];
                        BOOL hidden = NO;
                        NSInteger animation = UIStatusBarAnimationNone;
                        [invocation setArgument:&hidden atIndex:2];
                        [invocation setArgument:&animation atIndex:3];
                        [invocation invoke];
                    }
                }
            }
        }
        [self setupNeedRotation:NO];
        [self forceChangeOrientation:UIInterfaceOrientationPortrait];
    }
}

// MARK: - Delegate
// MARK: <WKNavigationDelegate>
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // 特殊 scheme 处理:打电话、发短信、发邮件
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [[URL scheme] lowercaseString];
    NSArray *schemeWhiteList = @[@"http", @"https"];
    if (NO == [schemeWhiteList containsObject:scheme] &&
        YES == [self.allowSchemes containsObject:scheme]) {
        
        LZAppUnit.openURL(URL);
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    // 自行决策访问请求
    if (self.decidePolicyHandler) {
        self.decidePolicyHandler(navigationAction, decisionHandler);
        return;
    }
    // 子页面拦截
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    if (self.extractSubLinkCompletionHander) {
        if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
            
            self.extractSubLinkCompletionHander(URL);
            actionPolicy = WKNavigationActionPolicyCancel;
        } else if (navigationAction.navigationType == WKNavigationTypeOther
                   && nil != navigationAction.sourceFrame
                   && nil != navigationAction.request
                   && nil != navigationAction.targetFrame.request
                   && NO == [[URL absoluteString] isEqualToString:LZWebEmptyURL]) {
            self.subWeb = YES;
        }
    }
    decisionHandler(actionPolicy);
}

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
    preferences:(WKWebpagePreferences *)preferences
decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences *))decisionHandler API_AVAILABLE(macos(10.15), ios(13.0)) {
    // 特殊 scheme 处理:打电话、发短信、发邮件
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [[URL scheme] lowercaseString];
    NSArray *schemeWhiteList = @[@"http", @"https"];
    if (NO == [schemeWhiteList containsObject:scheme] &&
        YES == [self.allowSchemes containsObject:scheme]) {
        
        LZAppUnit.openURL(URL);
        decisionHandler(WKNavigationActionPolicyCancel, preferences);
        return;
    }
    // 自行决策访问请求
    if (self.decidePolicyHandler) {
        self.decidePolicyHandler(navigationAction, ^(WKNavigationActionPolicy navigationActionPolicy) {
            decisionHandler(navigationActionPolicy, preferences);
        });
        return;
    }
    // 子页面拦截
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    if (self.extractSubLinkCompletionHander) {
        if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
            
            self.extractSubLinkCompletionHander(URL);
            actionPolicy = WKNavigationActionPolicyCancel;
        } else if (navigationAction.navigationType == WKNavigationTypeOther
                   && nil != navigationAction.sourceFrame
                   && nil != navigationAction.request
                   && nil != navigationAction.targetFrame.request
                   && NO == [[URL absoluteString] isEqualToString:LZWebEmptyURL]) {
            self.subWeb = YES;
        }
    }
    decisionHandler(actionPolicy, preferences);
}

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if (self.subWeb && self.extractSubLinkCompletionHander) {
        
        self.subWeb = NO;
        NSURL *url = webView.URL;
        self.extractSubLinkCompletionHander(url);
        decisionHandler(WKNavigationResponsePolicyCancel);
        [webView stopLoading];
        if ([webView canGoBack]) {
            [webView goBack];
        }
    } else {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView
didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    if (self.startLoadCallback) {
        self.startLoadCallback();
    }
    if ([self.customUserAgent isValidString]) {
    
        NSString *ua = self.webView.customUserAgent;
        if (nil == ua || 0 == ua.length || [ua rangeOfString:self.customUserAgent].location == NSNotFound) {
            @lzweakify(self);
            [self nativeInvokeJS:@"navigator.userAgent" completionHandler:^(NSString * _Nonnull response, NSError * _Nonnull error) {
                @lzstrongify(self);
                self.webView.customUserAgent = [response stringByAppendingFormat:@" %@", self.customUserAgent];
                LZLog(@"\nUserAgent:%@\ncustomUserAgent:%@", response, self.webView.customUserAgent);
            }];
        }
    }
}

- (void)webView:(WKWebView *)webView
didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webView:(WKWebView *)webView
didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if (self.finishLoadCallback) {
        self.finishLoadCallback();
    }
    if (self.displayRefresh) {
        [self stopRefresh];
    }
    if (self.displayEmptyPage) {
        [self hideEmptyDataSet:self.webView.scrollView];
    }
}

- (void)webView:(WKWebView *)webView
didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation
      withError:(NSError *)error {
    if (self.failedLoadCallback) {
        self.failedLoadCallback(error);
    }
    if (self.displayRefresh) {
        [self stopRefresh];
    }
    if (self.subWeb) return;
    if (self.displayEmptyPage && self.webNavigation == navigation) {
        
        NSString *js = @"document.documentElement.innerHTML";
        @lzweakify(self);
        [self nativeInvokeJS:js completionHandler:^(NSString * _Nonnull result, NSError * _Nonnull error) {
            @lzstrongify(self);
            if (result.length < 200) {
                [self showEmptyDataSet:self.webView.scrollView];
            }
        }];
    }
}

- (void)webView:(WKWebView *)webView
didFailNavigation:(null_unspecified WKNavigation *)navigation
      withError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webView:(WKWebView *)webView
didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.subWeb = NO;
}

- (void)webView:(WKWebView *)webView
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macos(10.11), ios(9.0)) {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [webView reload];
    });
}

- (void)webView:(WKWebView *)webView
authenticationChallenge:(NSURLAuthenticationChallenge *)challenge
shouldAllowDeprecatedTLS:(void (^)(BOOL))decisionHandler API_AVAILABLE(macos(11.0), ios(14.0)) {
    decisionHandler(YES);
}

// MARK: <WKUIDelegate>
- (void)webView:(WKWebView *)webView
runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:self.title
                                        message:message?:@""
                                 preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView
runJavaScriptConfirmPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(BOOL result))completionHandler {
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:self.title
                                        message:message?:@""
                                 preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView
runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(nullable NSString *)defaultText
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:self.title
                                        message:prompt?:@""
                                 preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"完成"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        
        NSArray *textFields = alertController.textFields;
        NSMutableArray *textArrM = [NSMutableArray arrayWithCapacity:textFields.count];
        for (UITextField *textField in textFields) {
            if (textField.hasText) {
                [textArrM addObject:textField.text];
            }
        }
        completionHandler([textArrM copy]);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (nullable WKWebView *)webView:(WKWebView *)webView
 createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
            forNavigationAction:(WKNavigationAction *)navigationAction
                 windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [webView loadRequest:navigationAction.request];
        });
    }
    return nil;
}

- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)) {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (BOOL)webView:(WKWebView *)webView
shouldPreviewElement:(WKPreviewElementInfo *)elementInfo API_AVAILABLE(ios(10.0)) {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return YES;
}
- (nullable UIViewController *)webView:(WKWebView *)webView
    previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo
                        defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions API_AVAILABLE(ios(10.0)) {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return nil;
}
- (void)webView:(WKWebView *)webView
commitPreviewingViewController:(UIViewController *)previewingViewController API_AVAILABLE(ios(10.0)) {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webView:(WKWebView *)webView
contextMenuConfigurationForElement:(WKContextMenuElementInfo *)elementInfo
completionHandler:(void (^)(UIContextMenuConfiguration * _Nullable configuration))completionHandler API_AVAILABLE(ios(13.0)) {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    completionHandler(nil);
}
- (void)webView:(WKWebView *)webView
contextMenuForElement:(WKContextMenuElementInfo *)elementInfo
willCommitWithAnimator:(id <UIContextMenuInteractionCommitAnimating>)animator API_AVAILABLE(ios(13.0)) {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
- (void)webView:(WKWebView *)webView
contextMenuDidEndForElement:(WKContextMenuElementInfo *)elementInfo API_AVAILABLE(ios(13.0)) {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webView:(WKWebView *)webView
requestMediaCapturePermissionForOrigin:(nonnull WKSecurityOrigin *)origin
initiatedByFrame:(nonnull WKFrameInfo *)frame
           type:(WKMediaCaptureType)type
decisionHandler:(nonnull void (^)(WKPermissionDecision))decisionHandler WK_SWIFT_ASYNC(5) API_AVAILABLE(macos(12.0), ios(15.0)) {
    decisionHandler(WKPermissionDecisionPrompt);
}

- (void)webView:(WKWebView *)webView
requestDeviceOrientationAndMotionPermissionForOrigin:(WKSecurityOrigin *)origin
initiatedByFrame:(WKFrameInfo *)frame
decisionHandler:(void (^)(WKPermissionDecision decision))decisionHandler API_AVAILABLE(ios(15.0)) API_UNAVAILABLE(macos) {
    decisionHandler(WKPermissionDecisionPrompt);
}

@end
