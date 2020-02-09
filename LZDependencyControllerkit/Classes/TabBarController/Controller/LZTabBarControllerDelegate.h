//
//  LZTabBarControllerDelegate.h
//  Pods
//
//  Created by Dear.Q on 16/8/11.
//
//

#import <Foundation/Foundation.h>
@class LZTabBar;

@protocol LZTabBarControllerDelegate <NSObject>

@required

/**
 @author Lilei
 
 @brief TaBBar点击事件
 
 @param myTabBar LZTabBar
 @param from   From
 @param to  To
 */
- (void)tabBarBtnDidClick:(LZTabBar *)myTabBar
                     from:(NSInteger)from
                       to:(NSInteger)to;

@optional

/**
 @author Lilei
 
 @brief 加号按钮点击事件
 
 @param myTabBar LZTabBar
 */
- (void)plusBtnDidCilck:(LZTabBar *)myTabBar;

/**
 @author Lilei
 
 @brief 默认选中索引
 
 @param myTabBar LZTabBar
 
 @return NSUInteger，从 0 开始
 */
- (NSUInteger)tabBarDefaultSelectedIndex:(LZTabBar *)myTabBar;

@end
