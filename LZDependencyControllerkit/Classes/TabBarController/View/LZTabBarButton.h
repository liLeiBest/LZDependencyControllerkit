//
//  LZTabBarButton.h
//  Pods
//
//  Created by Dear.Q on 16/8/11.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LZTabBarButtonType) {
    LZTabBarButtonTypeNormal,
    LZTabBarButtonTypePlus,
};
@interface LZTabBarButton : UIButton

/** 控件器的TabBarItem */
@property (nonatomic, strong) UITabBarItem *item;
/** 按钮类型 */
@property (nonatomic, assign) LZTabBarButtonType tabBarBtnType;


/// 更新标题和图片的比例
- (void)updateProportionOfTitleAndImage;

@end
