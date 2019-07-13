//
//  HXBaseWebViewController.h
//  Pods
//
//  Created by Dear.Q on 16/8/18.
//
//

#import <UIKit/UIKit.h>

/** web 默认的空 URL*/
UIKIT_EXTERN NSString * const HXWebDefaultEmptyURL;

typedef void (^HXBaseWebJSResponseCallback)(id rspData);
typedef void (^HXBaseWebJSHandler)(id data, HXBaseWebJSResponseCallback rspCallback);

@interface HXBaseWebViewController : UIViewController<UIWebViewDelegate>

/** UIWebView */
@property (nonatomic, strong, readonly) UIWebView *webView;
/** 请求地址URL */
@property (nonatomic, copy) NSString *urlString;

/** 返回按钮标题，默认为返回 */
@property (nonatomic, copy) NSString *navBackTitle;
/** 返回按钮图标 */
@property (nonatomic, copy) NSString *navBackIcon;
/** 关闭按钮标题，默认为关闭 */
@property (nonatomic, copy) NSString *navCloseTitle;
/** 关闭按钮图标 */
@property (nonatomic, copy) NSString *navCloseIcon;
/** 自动添加关闭 */
@property (nonatomic, assign) BOOL navAutoAddClose;

/** 是否显示进度条，默认为YES */
@property (nonatomic, assign) BOOL displayProgress;
/** 是否添加下拉刷新，默认为NO */
@property (nonatomic, assign) BOOL displayRefresh;
/** 是否显示空白页，默认为NO */
@property (nonatomic, assign) BOOL displayEmptyPage;
/** 界面消失后刷新界面，默认为NO。用于停止暴力停止多媒体播放，最好在 Disappear 方法,通过 JS 交互停止。 */
@property (nonatomic, assign) BOOL disappearToRefresh;

/** 是否允许内嵌 HTML5 播放视频还是用本地的全屏控制，默认为NO，本地的全屏控制。YES，video 元素必须包含webkit-playsinline属性 */
@property (nonatomic, assign) BOOL allowsInlineMediaPlayback;
/** HTML5 视频可以自动播放还是需要用户去启动播放，默认为YES */
@property (nonatomic, assign) BOOL mediaPlaybackRequiresUserAction;


/**
 @author Lilei
 
 @brief 加载URL页面
 
 @param url URL地址
 */
- (void)requestURL:(NSString *)url;

/**
 @author Lilei
 
 @brief 刷新当前页面
 */
- (void)refreshWebView;

/**
 @author Lilei
 
 @brief 关闭webView,
 @remark 用于modal出来的webView，交给子类实现
 */
- (void)closeWebView;

/**
 @author Lilei
 
 @brief 跳转到其它页面打开
 
 @param childWebView 要跳转的子页面
 @remark 子页面必须是 HXBaseWebViewController 子类，且展示方式为 Push。
 */
- (void)jumpToChildWebView:(void (^)(NSString *childWebView))childWebView;

/**
 @author Lilei
 
 @brief 启动 WebView 与 JS 桥接
 @remark 进度条显示与该冲突，同时只能启动一个。
 */
- (void)startWebViewJavascriptBridge;

/**
 @author Lilei
 
 @brief 停止 WebView 与 JS 桥接
 */
- (void)stopWebViewJavascriptBridge:(NSString *)handlerName;

/**
 @author Lilei
 
 @brief 注册 webView 与 JS 交互的方法及响应
 
 @param name 方法名
 @param hander 完成回调
 */
- (void)regiesterHandlerName:(NSString *)name
               finishHandler:(HXBaseWebJSHandler)hander;

/**
 @author Lilei
 
 @brief 调用 webView 与 JS 交互的方法及响应

 @param name 方法名
 @param paras 参数
 @param handler 完成回调
 */
- (void)callHandlerName:(NSString *)name
                  paras:(id)paras
          finishHandler:(HXBaseWebJSResponseCallback)handler;

@end
