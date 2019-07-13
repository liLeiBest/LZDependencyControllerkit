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

@interface LZTabBarViewController : UITabBarController

/** DataSource */
@property (nonatomic, weak) id<LZTabBarControllerDataSource> tabBarDataSource;
/** Delegate */
@property (nonatomic, weak) id<LZTabBarControllerDelegate> tabBarDelegate;


/**
 @author Lilei
 
 @brief 添加子控件
 
 @param childController 子控制器
 @param title           标题
 @param normalImg       正常图标
 @param selectedImg     高亮图标
 */
- (void)addChildViewController:(UIViewController *)childController
                         title:(NSString *)title
                     normalImg:(NSString *)normalImg
                   selectedImg:(NSString *)selectedImg;

@end
