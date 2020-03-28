//
//  LZStartPageConst.h
//  Pods
//
//  Created by Dear.Q on 2019/9/19.
//

#ifndef LZStartPageConst_h
#define LZStartPageConst_h

/// 页面关闭事件触发源
typedef NS_ENUM(NSUInteger, LZStartPageCloseTrigger) {
    /// 其它情况
    LZStartPageCloseTriggerOther = 0,
    /// 跳过
	LZStartPageCloseTriggerSkip = 1,
    /// 进入，正常关闭
	LZStartPageCloseTriggerEnter,
};

typedef NSString * LZStartPageNotificationKey NS_EXTENSIBLE_STRING_ENUM;

/// 启动页关闭通知
FOUNDATION_EXPORT NSNotificationName const LZStartPageDidCloseNotification;
/// 通知-关闭方式 Key
FOUNDATION_EXPORT LZStartPageNotificationKey const LZStartPageCloseNotificationTriggerKey;

#endif /* LZStartPageConst_h */
