//
//  LZGuideViewController.h
//  Pods
//
//  Created by Dear.Q on 2019/9/18.
//

#import <UIKit/UIKit.h>
#import "LZGuidePageDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface LZGuideViewController : UIViewController

/// 是否需要显示引导页，根据版本控制
/// @attention 每个版本显示一次，可以配置 clearTrigger，增加显示次数
+ (BOOL (^)(void))needGuide;
/// 清除触发条件
+ (void (^)(void))clearTrigger;
/// 更新触发条件
+ (void (^)(void))updateTrigger;
/// 实例
+ (LZGuideViewController * (^)(void))instance;

/// 代理
- (LZGuideViewController * (^)(id<LZGuidePageDelegate>))delegate;
/// 添加引导子控制器
- (LZGuideViewController * (^)(NSArray<UIViewController *> *))guideViewControllers;

// MARK: - <外观>
/// 默认配置
- (LZGuideViewController * (^)(void))defaultConfig;
/// 实时更新外观配置
- (LZGuideViewController * (^)(void))updateAppearance;

/// 是否显示跳过控件，默认 YES
- (LZGuideViewController * (^)(BOOL))showSkipControl;
/// 跳过控件标题，默认 跳过
- (LZGuideViewController * (^)(NSString *))skipTitlel;
/// 跳过控件标题颜色，默认  #000000
- (LZGuideViewController * (^)(UIColor *))skipTitleColor;
/// 跳过控制背景色，默认  #DAEEFF
- (LZGuideViewController * (^)(UIColor *))skipBGColor;

/// 是否显示页码控件，默认 YES
- (LZGuideViewController * (^)(BOOL))showPageControl;
/// 页码颜色，默认 #A9A6AA
- (LZGuideViewController * (^)(UIColor *))pageColor;
/// 当前页码颜色，默认  #299FF7
- (LZGuideViewController * (^)(UIColor *))currentPageColor;

/// 是否显示进入控件，默认 YES
- (LZGuideViewController * (^)(BOOL))showTheEntranceControl;
/// 入口控件标题，默认 立即体验
- (LZGuideViewController * (^)(NSString *))theEntranceTitle;
/// 入口控件标题颜色，默认 #FFFFFF
- (LZGuideViewController * (^)(UIColor *))theEntranceTitleColor;
/// 入口控件背景色，默认 #299FF7
- (LZGuideViewController * (^)(UIColor *))theEntranceBGColor;
/// 入口控件边框色，默认 #FFFFFF
- (LZGuideViewController * (^)(UIColor *))theEntranceBorderColor;

/// 是否无限滚动，默认 YES
- (LZGuideViewController * (^)(BOOL))infiniteScrolling;

@end

NS_ASSUME_NONNULL_END
