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
 
 @param myTabBar LZIrregularTabBar
 @param from     From
 @param to       To
 */
- (void)tabBarBtnDidClick:(LZTabBar *)myTabBar
                     from:(NSInteger)from
                       to:(NSInteger)to;

@optional

/**
 @author Lilei
 
 @brief 加号按钮点击事件
 
 @param myTabBar LZIrregularTabBar
 */
- (void)plusBtnDidCilck:(LZTabBar *)myTabBar;

@end
