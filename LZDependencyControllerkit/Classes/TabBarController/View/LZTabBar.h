//
//  LZTabBar.h
//  Pods
//
//  Created by Dear.Q on 16/8/11.
//  Copyright © 2016年 Dear.Q. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LZTabBar;

NS_ASSUME_NONNULL_BEGIN

typedef void(^LZTabBarBtnClickBlock)(LZTabBar *myTabBar, NSInteger from, NSInteger to);
typedef void(^LZTabBarPlusClickBlock)(LZTabBar *myTabBar);

@interface LZTabBar : UIView

/** TabBar按钮Normal状态的颜色 */
@property (nonatomic, strong) UIColor *tabBarBtnNormalColor;
/** TabBar按钮Selected状态的颜色 */
@property (nonatomic, strong) UIColor *tabBarBtnSelectedColor;
/** TabBar按钮的字体 */
@property (nonatomic, strong) UIFont *tabBarBtnFont;
/** 默认选中索引下标 */
@property (nonatomic, assign) NSUInteger defaultSelectedIndex;
/** 加号按钮偏移量 */
@property (nonatomic, assign) NSUInteger plusBtnOffsetY;
/** TaBBar按钮点击事件 */
@property (nonatomic, copy) LZTabBarBtnClickBlock tabBarBtnDidClickBlock;
/** 加号按钮点击事件 */
@property (nonatomic, copy) LZTabBarPlusClickBlock tabBarPulsBtnDidClickBlock;


/**
 @author Lilei
 
 @brief 实例带加号的TabBar
 
 @return LZTabBar
 */
- (LZTabBar *)initWithPlusBtn;

/**
 @author Lilei
 
 @brief 设置加号按钮的背景图片
 
 @param backgroundImage 背景图片
 @param state           UIControlState
 */
- (void)setupPlusBtnBackgroundImage:(UIImage *)backgroundImage
                           forState:(UIControlState)state;

/**
 @author Lilei
 
 @brief 设置加号按钮的图标
 
 @param image 图标
 @param state UIControlState
 */
- (void)setupPlusBtnImage:(UIImage *)image
                 forState:(UIControlState)state;

/**
 @author Lilei
 
 @brief 设置加号按钮标题
 
 @param title 标题
 @param state UIControlState
 */
- (void)setupPlusBtnTitle:(NSString *)title
                 forState:(UIControlState)state;

/**
 @author Lilei
 
 @brief 设置加号按钮标题
 
 @param title NSAttributedString
 @param state UIControlState
 */
- (void)setupPlusBtnAttributedTitle:(NSAttributedString *)title
                           forState:(UIControlState)state;

/**
 @author Lilei
 
 @brief 添加TabBarButton
 
 @param tabBarItem UITabBarItem
 */
- (void)addTabBarBtn:(UITabBarItem *)tabBarItem;

/**
 @ahutor Lilei
 
 @brief 更新选中项

 @param selectedIndex 索引
 */
- (void)updateSelectedIndex:(NSInteger)selectedIndex;

@end

NS_ASSUME_NONNULL_END
