//
//  LZWebViewController.m
//  Pods
//
//  Created by Dear.Q on 2017/4/7.
//
//

#import "LZWebViewController.h"
#import <objc/runtime.h>
#import "LZMarqueeLabel.h"

/**
 @author Lilei
 
 @brief 弱代理
 */
@interface LZWeakScriptMessageDelegate : NSObject<WKScriptMessageHandler>

/** 代理 */
@property (nonatomic, weak) id<WKScriptMessageHandler> delegate;
/** 保存 JS 回调 Block */
@property (nonatomic, copy) void (^completionHanderBlock)(WKScriptMessage *message);


/**
 @author Lilei
 
 @brief 实例
 
 @param scriptDelegate 代理
 @param handler 回调
 @return LZWeakScriptMessageDelegate
 */
- (instancetype)initWithDelegate:(id)scriptDelegate
               completionHandler:(void (^)(WKScriptMessage *message))handler;

@end

@implementation LZWeakScriptMessageDelegate

// MARK: - Public
/** 实例 */
- (instancetype)initWithDelegate:(id)scriptDelegate
               completionHandler:(void (^)(WKScriptMessage *))handler {
    if (self = [super init]) {
        
        _delegate = scriptDelegate;
        _completionHanderBlock = handler;
    }
    return self;
}

// MARK: -Delegate
// MARK: <WKScriptMessageHandler>
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if (self.completionHanderBlock) {
        self.completionHanderBlock(message);
    }
}

@end

NSString * const LZWebEmptyURL = @"about:blank";
static NSString * const LZWebProgress = @"estimatedProgress";
static NSString * const LZWebTitle = @"title";
static NSString * const LZURLSchemeTel = @"tel";
static NSString * const LZURLSchemeSms = @"sms";
static NSString * const LZURLSchemeMail = @"mailto";

@interface LZWebViewController ()
<WKNavigationDelegate, WKUIDelegate> {
    IMP _originalIMP;
}

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
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    }
    return _webView;
}

- (NSMutableDictionary *)scriptMessageContainer {
    if (nil == _scriptMessageContainer) _scriptMessageContainer = [NSMutableDictionary dictionary];
    return _scriptMessageContainer;
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.disappearToRefresh) {
        [self.webView reload];
    }
}

- (void)dealloc {
    NSLog(@"已经死去%s", __PRETTY_FUNCTION__);
    if (self.closeCompletionCallback) {
        self.closeCompletionCallback();
    }
    
    self.webView.navigationDelegate = nil;
    self.webView.UIDelegate = nil;
    
    @try {
        WKUserContentController *userCC = self.webView.configuration.userContentController;
        [self.scriptMessageContainer enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [userCC removeScriptMessageHandlerForName:key];
        }];
        
        [self.webView removeObserver:self forKeyPath:LZWebTitle];
        [self.webView removeObserver:self forKeyPath:LZWebProgress];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    } @catch (NSException *exception) {
        NSLog(@"移除 WebView 通知崩溃:%@", exception);
    } @finally {
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"Web页面内存警告!:%@", NSStringFromClass([self class]));
    [self.webView stopLoading];
    dispatch_after(0.25, dispatch_get_main_queue(), ^{
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
            Class appearanceClass = [UINavigationController class];
            UINavigationBar *theme = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[appearanceClass]];
            NSDictionary *attributes = [theme titleTextAttributes];
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
    [self.webView reloadFromOrigin];
}

- (void)reloadRequest {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.URL];
    self.webNavigation = [self.webView loadRequest:request];
}

- (void)JSInvokeNative:(NSString *)scriptMessage
    completionCallback:(void (^)(WKScriptMessage *))handler {
    NSAssert(nil != scriptMessage && scriptMessage.length, @"scriptMessage 不能空");
    if (handler) [self.scriptMessageContainer setObject:handler forKey:scriptMessage];
    // JS 调用 OC，添加处理脚本
    WKUserContentController *userCC = self.webView.configuration.userContentController;
    LZWeakScriptMessageDelegate *scriptMessageDelegate =
    [[LZWeakScriptMessageDelegate alloc] initWithDelegate:self
                                        completionHandler:^(WKScriptMessage *message) {
                                            if (handler) handler(message);
                                        }];
    [userCC addScriptMessageHandler:scriptMessageDelegate name:scriptMessage];
}

- (void)JSInvokeNative:(NSString *)scriptMessage
     completionHandler:(void (^)(id))handler {
    [self JSInvokeNative:scriptMessage completionCallback:^(WKScriptMessage *message) {
        if (handler) {
            handler(message.body);
        }
    }];
}

- (void)nativeInvokeJS:(NSString *)script
     completionHandler:(void (^)(id, NSError *))completionHandler {
    NSAssert(nil != script && script.length, @"script 不能为空");
    if (nil == script || !script.length) return;
    [self.webView evaluateJavaScript:script completionHandler:completionHandler];
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

// MARK: - UI Action
- (void)goBackDidClick {
    if (self.webView.canGoBack) {
        
        WKBackForwardList *backForwardList = [self.webView backForwardList];
        WKBackForwardListItem *backForwardItem = [[backForwardList backList] lastObject];
        if (self.gobackCallback) {
            self.gobackCallback(backForwardItem);
        }
        [self.webView goToBackForwardListItem:backForwardItem];
        return;
    }
    [self closeDidClick];
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
    
    self.rotationLandscape = NO;
    
    self.subWeb = NO;
}

- (void)initConfig {
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    
    NSHTTPCookieStorage *HTTPCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [HTTPCookie setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    [self configNavigation];
}

- (void)registerObserver {
    @try {
        [self.webView addObserver:self forKeyPath:LZWebTitle options:NSKeyValueObservingOptionNew context:NULL];
        [self.webView addObserver:self forKeyPath:LZWebProgress options:NSKeyValueObservingOptionNew context:NULL];
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

- (void)configRefreshControl {
    __weak typeof(self) weakSelf = self;
    [self.webView.scrollView headerWithRefreshingBlock:^{
        [weakSelf reloadRequest];
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
            if ([self.webView canGoBack]) self.navigationItem.leftBarButtonItems = @[back, close];
            else self.navigationItem.leftBarButtonItems = @[back];
        } else {
            self.navigationItem.leftBarButtonItems = @[back, close];
        }
    }
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

- (void)isNeedRotation:(BOOL)needRotation {

    id appDelegate = [UIApplication sharedApplication].delegate;
    
    Class destClass = [appDelegate class];
    SEL originalSEL = @selector(application:supportedInterfaceOrientationsForWindow:);
    const char *originalMethodType = method_getTypeEncoding(class_getInstanceMethod(destClass, originalSEL));
    if (YES == needRotation && nil == _originalIMP) {
        _originalIMP = method_getImplementation(class_getInstanceMethod(destClass, originalSEL));
    }
    __weak typeof(self) weakSelf = self;
    IMP newIMP = imp_implementationWithBlock(^(id obj, UIApplication *application, UIWindow *window) {
        if ([NSStringFromClass([[[window subviews] lastObject] class]) isEqualToString:@"UITransitionView"]) {
            if (needRotation) {
                [weakSelf forceChangeOrientation:UIInterfaceOrientationLandscapeRight];
            }
        }
        return needRotation ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
    });
    if (YES == needRotation) {
        class_replaceMethod(destClass, originalSEL, newIMP, originalMethodType);
    } else {
        class_replaceMethod(destClass, originalSEL, _originalIMP, originalMethodType);
    }
}

- (void)forceChangeOrientation:(UIInterfaceOrientation)orientation {
    
    SEL selector = NSSelectorFromString(@"setOrientation:");
    if ([[UIDevice currentDevice] respondsToSelector:selector]) {
        
        NSInvocation *invocation =
        [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        UIInterfaceOrientation val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

// MARK: - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual:LZWebProgress] && object == self.webView) {
        LZLog(@"Web load progress:%f", self.webView.estimatedProgress);
        if (self.displayProgress) {
            if (nil == self.progressView) {
                
                UIImage *bgImg = [self.navigationController.navigationBar backgroundImageForBarMetrics: UIBarMetricsDefault];
                BOOL translucent = self.navigationController.navigationBar.translucent;
                CGFloat y = 0;
                if (nil == bgImg || YES == translucent) {
                    y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
                }
                CGRect frame = CGRectMake(0, y, CGRectGetWidth(self.view.frame), 1);
                self.progressView = [[UIProgressView alloc] initWithFrame:frame];
                self.progressView.trackTintColor = self.progressTrackColor;
                self.progressView.progressTintColor = self.progressColor;
                [self.view addSubview:self.progressView];
            }
            [self.progressView setAlpha:1.0f];
            [UIView animateWithDuration:0.25 animations:^{
                [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
            }];
            if (self.progressHandler) {
                self.progressHandler(self.webView.estimatedProgress);
            }
            if (self.webView.estimatedProgress >= 1.0f) {
                [UIView animateWithDuration:0.25 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.progressView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [self.progressView setProgress:0.0f animated:NO];
                }];
            }
        }
    } else if ([keyPath isEqualToString:LZWebTitle] && object == self.webView) {
        if (self.showWebTitle) {
            if (NO == [self.title isValidString]) {
                self.title = self.webView.title;
            }
            if (NO == [self.title isEqualToString:self.webView.title]) {
                self.title = self.webView.title;
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)beginFullScreen:(NSNotification *)notifi {
    if (YES == self.rotationLandscape) {
        [self isNeedRotation:YES];
    }
}

- (void)endFullScreen:(NSNotification *)notifi {
    if (YES == self.rotationLandscape) {
        if (@available(iOS 12, *)) {
            
            UIWindow *window = (UIWindow *)notifi.object;
            if(window){
                
                UIViewController *rootViewController = window.rootViewController;
                NSArray<__kindof UIViewController *> *viewVCArray = rootViewController.childViewControllers;
                if ([viewVCArray.firstObject isKindOfClass:NSClassFromString(@"AVPlayerViewController")]) {
                    
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
        [self isNeedRotation:NO];
        [self forceChangeOrientation:UIInterfaceOrientationPortrait];
    }
}

// MARK: - Delegate
// MARK: <WKNavigationDelegate>
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // 自行决策访问请求
    if (self.decidePolicyHandler) {
        self.decidePolicyHandler(navigationAction, decisionHandler);
        return;
    }
    // 特殊 scheme 处理:打电话、发短信、发邮件
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [[URL scheme] lowercaseString];
    if ([scheme isEqualToString:LZURLSchemeTel]
        || [scheme isEqualToString:LZURLSchemeSms]
        || [scheme isEqualToString:LZURLSchemeMail]) {
        if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            if (@available(iOS 10, *)) {
                [[UIApplication sharedApplication] openURL:URL options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @(NO)} completionHandler:^(BOOL success) {
                }];
            } else {
                [[UIApplication sharedApplication] openURL:URL];
            }
        }
        decisionHandler(WKNavigationActionPolicyCancel);
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

#if 0
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
    preferences:(WKWebpagePreferences *)preferences
decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences *))decisionHandler API_AVAILABLE(macos(10.15), ios(13.0)) {
    // 自行决策访问请求
    if (self.decidePolicyHandler) {
        self.decidePolicyHandler(navigationAction, ^(WKNavigationActionPolicy navigationActionPolicy) {
            decisionHandler(navigationActionPolicy, preferences);
        });
        return;
    }
    // 特殊 scheme 处理:打电话、发短信、发邮件
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [[URL scheme] lowercaseString];
    if ([scheme isEqualToString:LZURLSchemeTel]
        || [scheme isEqualToString:LZURLSchemeSms]
        || [scheme isEqualToString:LZURLSchemeMail]) {
        if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            if (@available(iOS 10, *)) {
                [[UIApplication sharedApplication] openURL:URL options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @(NO)} completionHandler:^(BOOL success) {
                }];
            } else {
                [[UIApplication sharedApplication] openURL:URL];
            }
        }
        decisionHandler(WKNavigationActionPolicyCancel, preferences);
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
#endif

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
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webView:(WKWebView *)webView
didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webView:(WKWebView *)webView
didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
    [self correctNavigationButton];
    if (self.finishLoadCallback) {
        self.finishLoadCallback();
    }
    if (self.displayRefresh) {
        [self stopRefresh];
    }
    if (self.displayEmptyPage) {
        [self hideEmptyDataSet:self.webView.scrollView];
    }
    @lzweakify(self);
    [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString * _Nullable result, NSError * _Nullable error) {
        @lzstrongify(self);
        if ([self.customUserAgent isValidString]) {
            if ([result rangeOfString:self.customUserAgent].location == NSNotFound) {
                
                NSString *newUserAgent = [result stringByAppendingFormat:@" %@", self.customUserAgent];
                self.webView.customUserAgent = newUserAgent;
            }
        }
        LZLog(@"\nUserAgent:%@\ncustomUserAgent:%@", result, self.webView.customUserAgent);
    }];
}

- (void)webView:(WKWebView *)webView
didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation
      withError:(NSError *)error {
    if (self.failedLoadCallback) {
        self.failedLoadCallback();
    }
    if (self.displayRefresh) {
        [self stopRefresh];
    }
    if (self.subWeb) return;
    [self correctNavigationButton];
    if (self.displayEmptyPage && self.webNavigation == navigation) {
        [self showEmptyDataSet:self.webView.scrollView];
    }
}

- (void)webView:(WKWebView *)webView
didFailNavigation:(null_unspecified WKNavigation *)navigation
      withError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webView:(WKWebView *)webView
didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    LZLog(@"Web Recirect");
    self.subWeb = NO;
}

- (void)webView:(WKWebView *)webView
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macos(10.11), ios(9.0)) {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [webView reload];
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
        completionHandler(alertController.textFields[0].text?:@"");
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (nullable WKWebView *)webView:(WKWebView *)webView
 createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
            forNavigationAction:(WKNavigationAction *)navigationAction
                 windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        [webView loadRequest:navigationAction.request];
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

@end
