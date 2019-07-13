//
//  LZWebViewController.m
//  Pods
//
//  Created by Dear.Q on 2017/4/7.
//
//

#import "LZWebViewController.h"

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
/** ScriptMessage 容器 */
@property (nonatomic, strong) NSMutableDictionary *scriptMessageContainer;

@end

@implementation LZWebViewController

// MARK: - Lazy Loading
- (WKWebView *)webView {
	
    if (nil == _webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
		// 是否允许内嵌 HTML5 播放视频还是用本地的全屏控制，默认：NO，本地的全屏控制。YES，video 元素必须包含webkit-playsinline属性
		config.allowsInlineMediaPlayback = YES;
		// HTML5 视频可以自动播放还是需要用户去启动播放，默认为YES
		if (@available(iOS 10.0, *)) {
			config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
		} else if (@available(iOS 9, *)) {
			config.requiresUserActionForMediaPlayback = YES;
		} else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
			config.mediaPlaybackRequiresUserAction = YES;
#endif
		}
		config.allowsAirPlayForMediaPlayback = YES;
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
    }
    return _webView;
}

- (NSMutableDictionary *)scriptMessageContainer {
    if (nil == _scriptMessageContainer) _scriptMessageContainer = [NSMutableDictionary dictionary];
    return _scriptMessageContainer;
}

// MARK: - Initialization
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	
	if (self = [super initWithCoder:aDecoder]){
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
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.displayRefresh) {
		[self configRefreshControl];
	}
	
	if (self.displayEmptyPage) {
		self.emptyDataSetTitle = @"加载失败了~";
		self.emptyDataSetDetail = @"请稍后重试";
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
	
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
	
    self.webView.navigationDelegate = nil;
    self.webView.UIDelegate = nil;
    
    WKUserContentController *userCC = self.webView.configuration.userContentController;
    [self.scriptMessageContainer enumerateKeysAndObjectsUsingBlock:
	 ^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [userCC removeScriptMessageHandlerForName:key];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	[self.webView stopLoading];
    NSLog(@"Web页面内存警告!:%@", NSStringFromClass([self class]));
}

// MARK: - Setter
- (void)setURL:(NSURL *)URL {
    _URL = URL;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:_URL];
    [self.webView loadRequest:request];
}

// MARK: - Public
- (instancetype)initWithAttachView:(UIView *)view {
    if (self = [super init]) {
		
        [self.view addSubview:view];
        self.attachView = view;
    }
    return self;
}

- (void)reload {
	[self.webView reloadFromOrigin];
}

- (void)JSInvokeNative:(NSString *)scriptMessage
     completionHandler:(void (^)(id))handler {
	
    NSAssert(nil != scriptMessage && scriptMessage.length, @"scriptMessage 不能空");
    if (handler) [self.scriptMessageContainer setObject:handler forKey:scriptMessage];
    
    // JS 调用 OC，添加处理脚本
    WKUserContentController *userCC = self.webView.configuration.userContentController;
    LZWeakScriptMessageDelegate *scriptMessageDelegate =
    [[LZWeakScriptMessageDelegate alloc] initWithDelegate:self
                                        completionHandler:^(WKScriptMessage *message) {
											if (handler) handler(message.body);
										}];
    [userCC addScriptMessageHandler:scriptMessageDelegate name:scriptMessage];
}

- (void)nativeInvokeJS:(NSString *)script
     completionHandler:(void (^)(id, NSError *))completionHandler {
	
    NSAssert(nil != script && script.length, @"script 不能为空");
    if (nil == script || !script.length) return;
    [self.webView evaluateJavaScript:script completionHandler:completionHandler];
}

// MARK: - UI Action
- (void)goBackDidClick {
	
	if (self.webView.canGoBack) {
		
		WKBackForwardList *backForwardList = [self.webView backForwardList];
		WKBackForwardListItem *backForwardItem = [[backForwardList backList] lastObject];
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
	
	self.disappearToRefresh = NO;
	
	self.subWeb = NO;
}

- (void)initConfig {
	
	self.view.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:self.webView];
	
	NSHTTPCookieStorage *HTTPCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	[HTTPCookie setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
	
	[self registerObserver];
	
	[self configNavigationButton];
}

- (void)registerObserver {
	
	[self.webView addObserver:self
				   forKeyPath:LZWebProgress
					  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
					  context:nil];
	[self.webView addObserver:self
				   forKeyPath:LZWebTitle
					  options:NSKeyValueObservingOptionNew
					  context:NULL];
}

- (void)configRefreshControl {
	
	__weak typeof(self) weakSelf = self;
	[self.webView.scrollView headerWithRefreshingBlock:^{
		[weakSelf reload];
	}];
}

- (void)configNavigationButton {
	
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

// MARK: - NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
	
    if ([keyPath isEqual: @"estimatedProgress"] && object == self.webView) {
#if DEBUG
		NSLog(@"Web load progress:%f", self.webView.estimatedProgress);
#endif
		if (self.displayProgress) {
			if (nil == self.progressView) {
				
				CGFloat height = CGRectGetMaxY(self.navigationController.navigationBar.frame) + 1;
				CGRect frame = CGRectMake(0, height, CGRectGetWidth(self.view.frame), 1);
				self.progressView = [[UIProgressView alloc] initWithFrame:frame];
				self.progressView.trackTintColor = self.progressTrackColor;
				self.progressView.progressTintColor = self.progressColor;
				[self.view addSubview:self.progressView];
			}
			[self.progressView setAlpha:1.0f];
			[self.progressView setProgress:self.webView.estimatedProgress animated:YES];
			if (self.webView.estimatedProgress >= 1.0f) {
				
				[UIView animateWithDuration:0.3
									  delay:0.3
									options:UIViewAnimationOptionCurveEaseOut animations:^{
										[self.progressView setAlpha:0.0f];
									} completion:^(BOOL finished) {
										[self.progressView setProgress:0.0f animated:NO];
									}];
			}
		}
    } else if ([keyPath isEqualToString:@"title"] && object == self.webView) {
		if (self.showWebTitle) {
			if (self.showWebTitle) self.title = self.webView.title;
		}
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// MARK: - Delegate
// MARK: <WKNavigationDelegate>
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
	
    if (self.extractSubLinkCompletionHander && navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        self.subWeb = YES;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
	
    WKNavigationResponsePolicy rspPolicy = WKNavigationResponsePolicyAllow;
    if (self.subWeb && self.extractSubLinkCompletionHander) {
		
        NSURL *url = webView.URL;
        self.extractSubLinkCompletionHander(url);
        rspPolicy = WKNavigationResponsePolicyCancel;
    }
    decisionHandler(rspPolicy);
}

- (void)webView:(WKWebView *)webView
didFinishNavigation:(null_unspecified WKNavigation *)navigation {
	
	if (self.displayRefresh) {
		[self stopRefresh];
	}
	[self correctNavigationButton];
	if (self.displayEmptyPage) {
		[self hideEmptyDataSet:self.webView.scrollView];
	}
}

- (void)webView:(WKWebView *)webView
didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation
	  withError:(NSError *)error {
	
	if (self.displayRefresh) {
		[self stopRefresh];
	}
    if (self.subWeb) return;
	[self correctNavigationButton];
	if (self.displayEmptyPage) {
		[self showEmptyDataSet:self.webView.scrollView];
	}
}

- (void)webView:(WKWebView *)webView
didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
	NSLog(@"Web Recirect");
}

#if 0
- (void)webView:(WKWebView *)webView
didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
}
- (void)webView:(WKWebView *)webView
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
}
- (void)webView:(WKWebView *)webView
didCommitNavigation:(null_unspecified WKNavigation *)navigation {
}
- (void)webView:(WKWebView *)webView
didFailNavigation:(null_unspecified WKNavigation *)navigation
	  withError:(NSError *)error {
}
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)) {
}
#endif

// MARK: <WKUIDelegate>
- (void)webView:(WKWebView *)webView
runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(void))completionHandler {
	
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:self.title
                                        message:message?:@""
                                 preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction
                                actionWithTitle:@"确认"
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
    [alertController addAction:[UIAlertAction
                                actionWithTitle:@"取消"
                                style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction * _Nonnull action) {
									completionHandler(NO);
								}]];
    [alertController addAction:[UIAlertAction
                                actionWithTitle:@"确认"
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
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction
                                actionWithTitle:@"完成"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * _Nonnull action) {
									completionHandler(alertController.textFields[0].text?:@"");
								}]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#if 0
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
}
- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo API_AVAILABLE(ios(10.0))
{
}
- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0))
{
}
- (nullable UIViewController *)webView:(WKWebView *)webView
	previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo
						defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions API_AVAILABLE(ios(10.0))
{
}
- (void)webView:(WKWebView *)webView
commitPreviewingViewController:(UIViewController *)previewingViewController API_AVAILABLE(ios(10.0))
{
}
- (void)webView:(WKWebView *)webView
runOpenPanelWithParameters:(WKOpenPanelParameters *)parameters
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(NSArray<NSURL *> * _Nullable URLs))completionHandler API_AVAILABLE(macosx(10.12))
{
}
#endif

@end
