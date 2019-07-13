//
//  HXBaseWebViewController.m
//  Pods
//
//  Created by Dear.Q on 16/8/18.
//
//

#import "HXBaseWebViewController.h"
#import "UIScrollView+HXRefreshControl.h"
#import "UIViewController+HXEmptyDataSet.h"
#import "UIBarButtonItem+HXExtension.h"

#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"
#import "WebViewJavascriptBridge.h"

NSString * const HXWebDefaultEmptyURL = @"about:blank";

@interface HXBaseWebViewController ()
<NJKWebViewProgressDelegate,
UIScrollViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;
@property WebViewJavascriptBridge *bridge;

@end

@implementation HXBaseWebViewController

//MARK: - Lazy Loading
- (UIWebView *)webView {
    
    if (!_webView) {
        
        _webView = [[UIWebView alloc] init];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.scrollView.delegate = self;
        _webView.delegate = self;
    }
    
    return _webView;
}

- (NJKWebViewProgressView *)progressView {
    
    if (!_progressView) {
        
        _progressProxy = [[NJKWebViewProgress alloc] init];
        self.webView.delegate = _progressProxy;
        _progressProxy.webViewProxyDelegate = self;
        _progressProxy.progressDelegate = self;
        CGFloat progressBarHeight = 2.f;
        CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0,
                                     navigationBarBounds.size.height - progressBarHeight,
                                     navigationBarBounds.size.width,
                                     progressBarHeight);
        _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        _progressView.progress = 0.0;
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    
    return _progressView;
}

//MARK: - Initialization
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]){
        [self setupDefaultValue];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self setupDefaultValue];
    }
    
    return self;
}

- (instancetype)init {
    
    if (self = [super init]) {
        [self setupDefaultValue];
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.view = self.webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConfig];
    [self requestURL:self.urlString];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.displayProgress) {
        [self.navigationController.navigationBar addSubview:self.progressView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.displayProgress) {
        [self.progressView removeFromSuperview];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.disappearToRefresh) {
        [self requestURL:HXWebDefaultEmptyURL];
        [self requestURL:self.urlString];
    }
}

- (void)dealloc {
    NSLog(@"已经死去%@", [self class]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"Web页面内存警告!:%@", NSStringFromClass([self class]));
}

//MARK: - Setter
- (void)setAllowsInlineMediaPlayback:(BOOL)allowsInlineMediaPlayback {
    
    _allowsInlineMediaPlayback = allowsInlineMediaPlayback;
    self.webView.allowsInlineMediaPlayback = allowsInlineMediaPlayback;
}

- (void)setMediaPlaybackRequiresUserAction:(BOOL)mediaPlaybackRequiresUserAction {
    
    _mediaPlaybackRequiresUserAction = mediaPlaybackRequiresUserAction;
    self.webView.mediaPlaybackRequiresUserAction = mediaPlaybackRequiresUserAction;
}

//MARK: - Public
/** 加载URL页面 */
- (void)requestURL:(NSString *)url {
	
	NSURL *URL = [NSURL URLWithString:url];
	NSMutableURLRequest *requestM = [[NSMutableURLRequest alloc]
									 initWithURL:URL
									 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
									 timeoutInterval:10.0f];;
	[self.webView loadRequest:requestM];
}

/** 刷新当前页面 */
- (void)refreshWebView {
	[self requestURL:self.urlString];
}

/** 关闭当前页面 */
- (void)closeWebView{}

/** 跳转到其它页面打开 */
- (void)jumpToChildWebView:(void (^)(NSString *))childWebView{}

/** 启动 WebView 与 JS 桥接 */
- (void)startWebViewJavascriptBridge {
	
	[WebViewJavascriptBridge enableLogging];
	_bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
	[_bridge setWebViewDelegate:self];
}

/** 停止 WebView 与 JS 桥接 */
- (void)stopWebViewJavascriptBridge:(NSString *)handlerName {
	[_bridge removeHandler:handlerName];
}

/** 注册 WebView 与 JS 交互的方法及响应 */
- (void)regiesterHandlerName:(NSString *)name
			   finishHandler:(HXBaseWebJSHandler)hander {
	
	[_bridge registerHandler:name
					 handler:^(id data, WVJBResponseCallback responseCallback) {
						 if (hander) hander(data, responseCallback);
					 }];
}

/** 调用 WebView 与 JS 交互的方法及响应 */
- (void)callHandlerName:(NSString *)name
				  paras:(id)paras
		  finishHandler:(HXBaseWebJSResponseCallback)handler {
	
	[_bridge callHandler:name data:paras responseCallback:^(id responseData) {
		if (handler) handler(responseData);
	}];
}

//MARK: - Private
/**
 @author Lilei
 
 @brief 设置默认值
 */
- (void)setupDefaultValue {
    
    self.navBackTitle = @"返回";
    self.navCloseTitle = @"关闭";
	self.navAutoAddClose = NO;
    self.disappearToRefresh = NO;
    self.displayProgress = YES;
    self.displayRefresh = NO;
    self.displayEmptyPage = NO;
    self.urlString = HXWebDefaultEmptyURL;
}

/**
 @author Lilei
 
 @brief 初始配置
 */
- (void)initConfig {

    self.view.backgroundColor = [UIColor whiteColor];
    
    NSHTTPCookieStorage *HTTPCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [HTTPCookie setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    if (self.displayRefresh) [self configRefreshControl];
    [self configNavigationButton];
}

/**
 @author Lilei
 
 @brief 设置刷新控制
 */
- (void)configRefreshControl {
    
    __weak typeof(self) weakSelf = self;
    [self.webView.scrollView headerWithRefreshingBlock:^{
         [weakSelf refreshWebView];
    }];
}

/**
 @author Lilei
 
 @brief 停止刷新
 */
- (void)stopRefresh {
    [self.webView.scrollView endHeaderRefresh];
}

/**
 @author Lilei
 
 @brief Push 方式展示
 */
- (BOOL)isPush {
    return self.navigationController.topViewController == self && self.navigationController.viewControllers.count > 1;
}

/**
 @author Lilei
 
 @brief Present 方式展示
 */
- (BOOL)isPresent {
    return self.presentingViewController != nil;
}

/**
 @author Lilei
 
 @biref 判断是否应该添加导航按钮
 @discussion 1.不是栈顶控制器；2.是导航控制器
 */
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

/**
 @author Lilei
 
 @brief 设置导航栏按钮
 */
- (void)configNavigationButton {
    
    if ([self shouldAddNavItem]) {
        
        UIBarButtonItem *back = [UIBarButtonItem itemWithTitle:self.navBackTitle
                                                   normalImage:self.navBackIcon
                                                highlightImage:nil
                                                  disableImage:nil
                                                        target:self
                                                        action:@selector(goBackDidClick)];
        self.navigationItem.leftBarButtonItems = @[back];
    }
}

/**
 @author Lilei
 
 @brief 纠正导航栏按钮
 */
- (void)correctNavigationButton {
    
    if ([self shouldAddNavItem]) {
        
        UIBarButtonItem *back = [UIBarButtonItem itemWithTitle:self.navBackTitle
                                                   normalImage:self.navBackIcon
                                                highlightImage:nil
                                                  disableImage:nil
                                                        target:self
                                                        action:@selector(goBackDidClick)];
        UIBarButtonItem *close = [UIBarButtonItem itemWithTitle:self.navCloseTitle
                                                    normalImage:self.navCloseIcon
                                                 highlightImage:nil
                                                   disableImage:nil
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

/**
 @author Lilei
 
 @brief 返回按钮响应
 */
- (void)goBackDidClick {
    
    if (self.webView.canGoBack) {
        [self.webView goBack];
        return;
    }
    
    [self closeDidClick];
}

/**
 @author Lilei
 
 @brief 关闭按钮响应
 */
- (void)closeDidClick {
    
    if ([self isPush]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([self isPresent]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        if ([self respondsToSelector:@selector(closeWebView)]) {
            [self performSelector:@selector(closeWebView)
                       withObject:nil];
        }
    }
}

//MARK: - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress
        updateProgress:(float)progress {
    [self.progressView setProgress:progress animated:YES];
}

//MARK: - UIWebView
//MARK: <UIWebViewDelegate>
- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
	NSString *requestUrl = request.URL.absoluteString;
	if (navigationType == UIWebViewNavigationTypeLinkClicked ||
		(navigationType == UIWebViewNavigationTypeOther &&
		 ![requestUrl isEqualToString:HXWebDefaultEmptyURL] &&
		 ![self.urlString isEqualToString:requestUrl])) {
        
        if ([self respondsToSelector:@selector(jumpToChildWebView:)]) {
            
            [self jumpToChildWebView:^(NSString *childWebView) {
                
                 Class childClass = NSClassFromString(childWebView);
                 HXBaseWebViewController *childView = [[childClass alloc] init];
                 childView.urlString = [request.URL absoluteString];
                 [self.navigationController pushViewController:childView
                                                      animated:YES];
                 [webView stopLoading];
            }];
        }
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView
        didFailLoadWithError:(NSError *)error {
    
    // 设置进度条
    if (self.displayProgress) {
        self.progressView.progress = 0.0;
    }
    
    if ([error code] == NSURLErrorCancelled) {
        return;
    }
    
    // 停止刷新
    if (self.displayRefresh) {
        [self stopRefresh];
    }
    
    // 设置空白页
    NSString *allHTML = [_webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
    if (self.displayEmptyPage && allHTML.length < 30) {
        [self showEmptyDataSet:self.webView.scrollView];
    }
    
    [self correctNavigationButton];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    // 设置进度条
    if (self.displayProgress) {
        self.progressView.progress = 1.0;
    }
    
    // 设置空白页
    NSString *loadURLString = webView.request.URL.absoluteString;
    if ((nil == loadURLString || [loadURLString hasPrefix:@"about:"]) &&
         self.displayEmptyPage) {
        [self showEmptyDataSet:self.webView.scrollView];
    } else {
        [self hideEmptyDataSet:self.webView.scrollView];
    }
    
    // 停止刷新
    if (self.displayRefresh) {
        [self stopRefresh];
    }
    
    // 显示标题
    if (!self.title) {
        self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    
    [self correctNavigationButton];
}

@end
