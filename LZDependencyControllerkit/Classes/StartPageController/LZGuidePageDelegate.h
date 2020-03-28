//
//  LZGuidePageDelegate.h
//  Pods
//
//  Created by Dear.Q on 2019/9/19.
//

#import <Foundation/Foundation.h>
#import "LZStartPageConst.h"
@class LZGuideViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol LZGuidePageDelegate <NSObject>

@optional

/**
 引导页关闭响应事件
 
 @param guideViewController LZGuideViewController
 @param currentIndex 当前索引，从 0 开始
 @param closeTrigger LZGuideViewController
 */
- (void)guideViewController:(LZGuideViewController *)guideViewController
			   currentIndex:(NSUInteger)currentIndex
			didCloseTrigger:(LZStartPageCloseTrigger)closeTrigger;

@end

NS_ASSUME_NONNULL_END
