//
//  LZTabBarControllerDataSource.h
//  Pods
//
//  Created by Dear.Q on 16/8/15.
//
//

#import <Foundation/Foundation.h>
@class LZTabBar;

/** 加号按钮图标 */
UIKIT_EXTERN NSString * const LZTabBarPlusBtnImage;
/** 加号按钮背景 */
UIKIT_EXTERN NSString * const LZTabBarPlusBtnBackgroundImage;
/** 加号按钮标题 */
UIKIT_EXTERN NSString * const LZTabBarPlusBtnAttributedTitle;

/** 普通按钮正常状态颜色 */
UIKIT_EXTERN NSString * const LZTabBarTitleNormalColor;
/** 普通按钮选中状态颜色 */
UIKIT_EXTERN NSString * const LZTabBarTitleSelectedColor;
/** 普通按钮字体 */
UIKIT_EXTERN NSString * const LZTabBarTitleFont;

@protocol LZTabBarControllerDataSource <NSObject>

@optional

/**
 @author Lilei
 
 @brief 是否显示加号按钮
 
 @return YES Or NO
 */
- (BOOL)tabBarWhetherToShowPlusBtn;

/**
 @author Lilei
 
 @brief TabBar按钮的属性
 
 @param myTabBar LZTabBar
 
 @return  NSDictionary
 */
- (NSDictionary *)tabBarBtnAttributes:(LZTabBar *)myTabBar;

/**
 @author Lilei
 
 @brief 加号按钮的属性
 
 @param myTabBar LZTabBar
 
 @return NSDictionary
 */
- (NSDictionary *)tabBarPlusAttributes:(LZTabBar *)myTabBar;

/**
 @author Lilei
 
 @brief TabBar背景图片
 
 @param myTabBar LZTabBar
 
 @return UIImage
 */
- (UIImage *)tabBarBackgroundImage:(LZTabBar *)myTabBar;

/**
 @author Lilei
 
 @brief TabBar背景颜色
 
 @param myTabBar LZTabBar
 
 @return UIColor
 */
- (UIColor *)tabBarBackgroundColor:(LZTabBar *)myTabBar;

/**
 @author Lilei
 
 @brief 是否显示加顶部黑线
 
 @return YES Or NO
 */
- (BOOL)tabBarWhetherToshowTopBlackLine;

/**
 @author Lilei
 
 @brief 顶部黑线颜色
 
 @param myTabBar LZTabBar
 
 @return UIColor
 */
- (UIColor *)tabBarTopBlackLineColor:(LZTabBar *)myTabBar;


/**
@author Lilei

@brief 加号按钮向上偏移量，图景图也会在相应位置进行拉伸

@param myTabBar LZTabBar
 
@return NSUInteger
*/
- (NSUInteger)tabBarPlusBtnOffsetY:(LZTabBar *)myTabBar;

@end
