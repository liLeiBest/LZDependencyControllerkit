//
//  LZAdvertisingViewController.h
//  Pods
//
//  Created by Dear.Q on 2019/9/18.
//

#import <UIKit/UIKit.h>
#import "LZAdvertisingPageDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface LZAdvertisingViewController : UIViewController

/// 实例
+ (LZAdvertisingViewController * (^)(void))instance;
/// 代理
- (LZAdvertisingViewController * (^)(id<LZAdvertisingPageDelegate>))delegate;

// MARK: - <外观>
/// 默认配置
- (LZAdvertisingViewController * (^)(void))defaultConfig;
/// 更新外观
- (LZAdvertisingViewController * (^)(void))updateAppearance;

/// 是否显示跳过控件，默认 YES
- (LZAdvertisingViewController * (^)(BOOL))showSkipControl;
/// 跳过控件等待秒数，默认 3 秒
- (LZAdvertisingViewController * (^)(NSUInteger))skipWaitSeconds;
/// 跳过控件标题，默认 跳过
- (LZAdvertisingViewController * (^)(NSString *))skipTitlel;
/// 跳过控件标题颜色，默认  #000000
- (LZAdvertisingViewController * (^)(UIColor *))skipTitleColor;
/// 跳过控制背景色，默认 #DAEEFF
- (LZAdvertisingViewController * (^)(UIColor *))skipBGColor;

@end

NS_ASSUME_NONNULL_END
