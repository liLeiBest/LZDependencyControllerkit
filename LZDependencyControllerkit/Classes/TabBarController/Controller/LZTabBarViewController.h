//
//  LZTabBarViewController.h
//  Pods
//
//  Created by Dear.Q on 16/8/11.
//
//

#import <UIKit/UIKit.h>
#import "LZTabBarControllerDataSource.h"
#import "LZTabBarControllerDelegate.h"

/*
 Badge 显示规则：0不显示；>0显示数字；<0显示红点
 **/
@interface LZTabBarViewController : UITabBarController

/** DataSource */
@property (nonatomic, weak) id<LZTabBarControllerDataSource> tabBarDataSource;
/** Delegate */
@property (nonatomic, weak) id<LZTabBarControllerDelegate> tabBarDelegate;


/// 添加子控件
/// @param childViewController 子控制器
/// @param title 标题
/// @param normalImg 正常图标
/// @param selectedImg 选中图标
- (void)addChildViewController:(UIViewController *)childViewController
                         title:(NSString *)title
                     normalImg:(UIImage *)normalImg
                   selectedImg:(UIImage *)selectedImg;

/// 更新子控件
/// @param childViewController 子控制器
/// @param index 索引
/// @param title 标题
/// @param normalImg 正常图标
/// @param selectedImg 选中图标
- (void)updateChildViewController:(UIViewController *)childViewController
                            index:(NSUInteger)index
                            title:(NSString *)title
                        normalImg:(UIImage *)normalImg
                      selectedImg:(UIImage *)selectedImg;

/// 更新子控件
/// @param index 索引
/// @param title 标题
/// @param normalImg 正常图标
/// @param selectedImg 选中图标
- (void)updateChildViewControllerIndex:(NSUInteger)index
                                 title:(NSString *)title
                             normalImg:(UIImage *)normalImg
                           selectedImg:(UIImage *)selectedImg;

/// 移动系统按钮
- (void)removeSysTabarButton;

@end
