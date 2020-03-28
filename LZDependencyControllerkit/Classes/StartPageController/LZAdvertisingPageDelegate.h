//
//  LZAdvertisingPageDelegate.h
//  Pods
//
//  Created by Dear.Q on 2019/9/19.
//

#import <Foundation/Foundation.h>
#import "LZStartPageConst.h"
@class LZAdvertisingViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol LZAdvertisingPageDelegate <NSObject>

@optional

/**
 广告页关闭响应事件
 
 @param advertisingViewController LZAdvertisingViewController
 @param closeTrigger LZStartPageCloseTrigger
 */
- (void)advertisingViewController:(LZAdvertisingViewController *)advertisingViewController
				  didCloseTrigger:(LZStartPageCloseTrigger)closeTrigger;

/**
 广告页图片 URL
 
 @param advertisingViewController LZAdvertisingViewController
 */
- (NSURL *)advertisingViewControllerForCoverAd:(LZAdvertisingViewController *)advertisingViewController;

@end

NS_ASSUME_NONNULL_END
