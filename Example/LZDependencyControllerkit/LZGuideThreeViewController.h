//
//  LZGuideThreeViewController.h
//  Pods
//
//  Created by Dear.Q on 2019/9/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LZGuideThreeViewController : UIViewController

/// 立即体验点击回调
@property (nonatomic, copy) void (^exprienceDidTouchCallback)(void);


/**
 实例
 
 @return LZGuideThreeViewController
 */
+ (instancetype)instance;

@end

NS_ASSUME_NONNULL_END
