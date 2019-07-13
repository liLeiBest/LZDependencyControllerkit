//
//  LZBadgeButton.h
//  Pods
//
//  Created by Dear.Q on 16/8/12.
//
//

#import <UIKit/UIKit.h>

@interface LZLoadingButton : UIView

/** 边框颜色 */
@property (nonatomic, strong) UIColor *shapeColor;
/** 点击圆圈颜色 */
@property (nonatomic, strong) UIColor *circleColor;
/** 遮盖颜色 */
@property (nonatomic, strong) UIColor *maskColor;
/** 加载颜色 */
@property (nonatomic, strong) UIColor *loadColor;
/** 最短动画时间 */
@property (nonatomic, assign) NSTimeInterval minAnimationTime;


/**
 唯一实例方法

 @param title       按钮标题
 @param titleColor  标题颜色
 @param borderColor 边框颜色
 @param frame       Frame

 @return LZButton
 */
- (instancetype)initWithTitle:(NSString *)title
                   titleColor:(UIColor *)titleColor
                  borderColor:(UIColor *)borderColor
                        frame:(CGRect)frame;

/**
 添加点击事件

 @param target        Target
 @param action        SEL
 */
- (void)addTarget:(id)target
           action:(SEL)action;

/**
 结束动画
 */
- (void)animationFinish;

@end
