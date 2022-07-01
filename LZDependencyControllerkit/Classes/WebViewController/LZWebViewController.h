//
//  LZWebViewController.h
//  Pods
//
//  Created by Dear.Q on 2017/4/7.
//
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

/** web 默认的空 URL */
UIKIT_EXTERN NSString * const LZWebEmptyURL;

@interface LZWebViewController : UIViewController

/** 浏览器 */
@property (nonatomic, strong, readonly) WKWebView *webView;
/** 请求 URL */
@property (nonatomic, strong) NSURL *URL;

// MARK: - 以下配置应在 setURL: 之前调用，最好在 loadView 方法赋值
/** 自定 UA */
@property (nonatomic, copy) NSString *customUserAgent;

/** 返回按钮标题，默认 返回 */
@property (nonatomic, copy, nullable) NSString *navBackTitle;
/** 返回按钮图标，UIImage、NSString */
@property (nonatomic, strong, nullable) id navBackIcon;
/** 关闭按钮标题，默认 关闭 */
@property (nonatomic, copy, nullable) NSString *navCloseTitle;
/** 关闭按钮图标 ，UIImage、NSString */
@property (nonatomic, strong, nullable) id navCloseIcon;
/** 自动添加关闭，默认：NO  */
@property (nonatomic, assign) BOOL navAutoAddClose;

/** 是否显示网页标题，默认：YES */
@property (nonatomic, assign) BOOL showWebTitle;

/** 是否显示进度条，默认：YES */
@property (nonatomic, assign) BOOL displayProgress;
/** 进度条颜色，默认：[UIColor blueColor] */
@property (nonatomic, strong) UIColor *progressColor;
/** 进度条轨道颜色，默认：[UIColor clearColor] */
@property (nonatomic, strong) UIColor *progressTrackColor;
/** 加载进度回调 */
@property (nonatomic, copy) void (^progressHandler)(CGFloat progress);

/** 是否添加下拉刷新，默认：NO，无下拉刷新 */
@property (nonatomic, assign) BOOL displayRefresh;

/** 是否显示空白页，默认：NO，不显示空白页 */
@property (nonatomic, assign) BOOL displayEmptyPage;

/** 界面消失后刷新界面，默认：NO。用于暴力停止多媒体播放，最好在 Disappear 方法,通过 JS 交互停止。 */
@property (nonatomic, assign) BOOL disappearToRefresh;

/** 允许打开的 scheme，默认：@[@"tel", @"sms", @"mailto"] */
@property (nonatomic, strong) NSMutableArray *allowSchemes;

/** 自行决策是否允许继续访问 */
@property (nonatomic, copy) void (^ __nullable decidePolicyHandler)(WKNavigationAction *navigationAction, void (^decisionHandler)(WKNavigationActionPolicy navigationActionPolicy));
/** 挂载子链接完成回调 */
@property (nonatomic, copy) void (^ __nullable extractSubLinkCompletionHander)(NSURL *linkURL);

/** 是否允许内嵌 HTML5 播放视频还是用本地的全屏控制，默认为 NO，本地的全屏控制；YES，video 元素必须包含webkit-playsinline属性 */
@property (nonatomic, assign) BOOL allowsInlineMediaPlayback;
/** HTML5 音视频需要用户去触发播放还是自动播放，默认为 NO 自动播放；YES，手动播放 */
@property (nonatomic, assign) BOOL mediaPlaybackRequiresUserAction;

/** 是否允许横屏，默认 NO，不允许 */
@property (nonatomic, assign) BOOL rotationLandscape;

/** 完成加载回调 */
@property (nonatomic, copy) void (^ __nullable finishLoadCallback)(void);
/** 加载失败回调 */
@property (nonatomic, copy) void (^ __nullable failedLoadCallback)(void);
/** Go back 回调 */
@property (nonatomic, copy) void (^ __nullable gobackCallback)(WKBackForwardListItem *backForwardItem);
/** 页面关闭回调 */
@property (nonatomic, copy) void (^ __nullable closeCompletionCallback)(void);
// MARK: -


/**
 @author Lilei
 
 @brief 添加附加视图

 @param view UIView
 @return LZWebViewController
 @remark 目前只支持添加底部视图
 */
- (instancetype)initWithAttachView:(UIView *)view;

/**
 @author Lilei
 
 @brief 重新加载页面
 */
- (void)reloadPage;

/**
@author Lilei

@brief 重新加载请求
*/
- (void)reloadRequest;

/**
 @author Lilei
 
 @brief JS 调用 OC

 @param scriptMessage 消息
 @param handler 回调
 */
- (void)JSInvokeNative:(NSString *)scriptMessage
    completionCallback:(void (^ _Nullable)(WKScriptMessage *message))handler;

/**
 @author Lilei
 
 @brief JS 调用 OC

 @param scriptMessage 消息
 @param handler 回调
 */
- (void)JSInvokeNative:(NSString *)scriptMessage
     completionHandler:(void (^ _Nullable)(id message))handler;

/**
 @author Lilei
 
 @brief OC 调用 JS

 @param script JS 脚本
 @param completionHandler 回调
 */
- (void)nativeInvokeJS:(NSString *)script
     completionHandler:(void (^ _Nullable)(id response, NSError *error))completionHandler;

/**
@author Lilei

@brief 是否自动添加导航按钮

@attention 可以重写此方法，防止自定义导航按钮被覆盖
*/
- (BOOL)shouldAddNavItem;

/**
@author Lilei

@brief 重置webView
*/
- (void)resetWebview;

@end

NS_ASSUME_NONNULL_END
