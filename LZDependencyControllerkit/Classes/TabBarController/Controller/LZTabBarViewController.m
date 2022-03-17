//
//  LZTabBarViewController.m
//  Pods
//
//  Created by Dear.Q on 16/8/11.
//
//

#import "LZTabBarViewController.h"
#import <objc/runtime.h>
#import "LZTabBar.h"

NSString * const LZTabBarPlusBtnImage = @"LZTabBarPlusBtnImage";
NSString * const LZTabBarPlusBtnBackgroundImage = @"LZTabBarPlusBtnBackgroundImage";
NSString * const LZTabBarPlusBtnAttributedTitle = @"LZTabBarPlusBtnAttributedTitle";

NSString * const LZTabBarTitleNormalColor = @"LZTabBarTitleNormalColor";
NSString * const LZTabBarTitleSelectedColor = @"LZTabBarTitleSelectedColor";
NSString * const LZTabBarTitleFont = @"LZTabBarTitleFont";

@interface LZTabBarViewController ()

/** 自定义TabBar */
@property (nonatomic, weak) LZTabBar *myTabBar;
/** 是否带加号按钮 */
@property (nonatomic, assign, getter = isShowPlusBtn) BOOL showPlusBtn;

@end

@implementation LZTabBarViewController

// MARK: - Initialization
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showPlusBtn = NO;
    [self _setupTabBar];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self _removeSysTabarButton];
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
    
    if (nil == viewControllers || 0 == viewControllers.count) {
        for (UIView *subView in self.myTabBar.subviews) {
            [subView removeFromSuperview];
        }
    }
    [self _setupTabBar];
}

#pragma mark - Public
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    
    [self.myTabBar updateSelectedIndex:selectedIndex];
}

- (void)addChildViewController:(UIViewController *)childViewController
                         title:(NSString *)title
                     normalImg:(UIImage *)normalImg
                   selectedImg:(UIImage *)selectedImg {
    
	[self addChildViewController:childViewController];
	UIViewController *viewController = [self _configChildViewController:childViewController title:title normalImg:normalImg selectedImg:selectedImg];
	[self.myTabBar addTabBarBtn:viewController.tabBarItem];
}

- (void)updateChildViewController:(UIViewController *)childViewController
                            index:(NSUInteger)index
                            title:(NSString *)title
                        normalImg:(UIImage *)normalImg
                      selectedImg:(UIImage *)selectedImg {
    
    NSMutableArray *childControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    [childControllers replaceObjectAtIndex:index withObject:childViewController];
    [self setViewControllers:[childControllers copy] animated:YES];
    UIViewController *viewController = [self _configChildViewController:childViewController title:title normalImg:normalImg selectedImg:selectedImg];
    [self.myTabBar updateTabBarBtn:viewController.tabBarItem index:index];
    [self _removeSysTabarButton];
}

- (void)updateChildViewControllerIndex:(NSUInteger)index
                                 title:(NSString *)title
                             normalImg:(UIImage *)normalImg
                           selectedImg:(UIImage *)selectedImg {
    if (self.viewControllers.count <= index) {
        return;
    }
    UIViewController *childViewController = self.viewControllers[index];
    UIViewController *viewController = [self _configChildViewController:childViewController title:title normalImg:normalImg selectedImg:selectedImg];
    [self.myTabBar updateTabBarBtn:viewController.tabBarItem index:index];
    [self _removeSysTabarButton];
}

// MARK: - Private
- (void)_setupTabBar {
    // 实例LZTabBar
    LZTabBar *tabBar = nil;
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarWhetherToShowPlusBtn)]) {
        self.showPlusBtn = [self.tabBarDataSource tabBarWhetherToShowPlusBtn];
    }
    if (self.isShowPlusBtn) {
        
        tabBar = [[LZTabBar alloc] initWithPlusBtn];
        tabBar.frame = self.myTabBar ? self.myTabBar.bounds : self.tabBar.bounds;
    } else {
        tabBar = [[LZTabBar alloc] initWithFrame:self.myTabBar ? self.myTabBar.bounds : self.tabBar.bounds];
    }
    self.myTabBar = tabBar;
    [self.tabBar addSubview:tabBar];
    // 设置TabBarButton
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarBtnAttributes:)]) {
        
        NSDictionary *attributes = [self.tabBarDataSource tabBarBtnAttributes:self.myTabBar];
        self.myTabBar.tabBarBtnNormalColor = [attributes objectForKey:LZTabBarTitleNormalColor];
        self.myTabBar.tabBarBtnSelectedColor = [attributes objectForKey:LZTabBarTitleSelectedColor];
        self.myTabBar.tabBarBtnFont = [attributes objectForKey:LZTabBarTitleFont];
    }
    // 设置加号按钮
    if (self.isShowPlusBtn &&
        [self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarPlusAttributes:)]) {
        
        NSDictionary *plusAttributes = [self.tabBarDataSource tabBarPlusAttributes:self.myTabBar];
        [self.myTabBar setupPlusBtnBackgroundImage:[plusAttributes objectForKey:LZTabBarPlusBtnBackgroundImage]
                                   forState:UIControlStateNormal];
        [self.myTabBar setupPlusBtnImage:[plusAttributes objectForKey:LZTabBarPlusBtnImage]
                         forState:UIControlStateNormal];
        [self.myTabBar setupPlusBtnAttributedTitle:[plusAttributes objectForKey:LZTabBarPlusBtnAttributedTitle]
                                   forState:UIControlStateNormal];
    }
    
    if (@available(iOS 100.0, *)) {
        
        UITabBarAppearance *appearance = self.tabBar.standardAppearance;
        if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
            [self.tabBarDataSource respondsToSelector:@selector(tabBarBackgroundImage:)]) {
            
            appearance.backgroundImage = [self.tabBarDataSource tabBarBackgroundImage:self.myTabBar];
            appearance.backgroundImageContentMode = UIViewContentModeScaleAspectFill;
        }
        appearance.backgroundColor = LZOrangeColor;
        if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
            [self.tabBarDataSource respondsToSelector:@selector(tabBarBackgroundColor:)]) {
            appearance.backgroundColor = [self.tabBarDataSource tabBarBackgroundColor:self.myTabBar];
        }
        if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
            [self.tabBarDataSource respondsToSelector:@selector(tabBarWhetherToshowTopBlackLine)]) {
            if (NO == [self.tabBarDataSource tabBarWhetherToshowTopBlackLine]) {
                
                appearance.shadowColor = [UIColor clearColor];
                appearance.shadowImage = [UIImage new];
            }
        }
        [self.tabBar setStandardAppearance:appearance];
    } else {
    }
    // TabBar背景
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarBackgroundImage:)]) {
        
        UIImage *backgroundImage = [self.tabBarDataSource tabBarBackgroundImage:self.myTabBar];
        self.myTabBar.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
        [[UITabBar appearance] setBackgroundImage:backgroundImage];
    }
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarBackgroundColor:)]) {
        
        UIColor *backgroundColor = [self.tabBarDataSource tabBarBackgroundColor:self.myTabBar];
        self.myTabBar.backgroundColor = backgroundColor;
        [[UITabBar appearance] setBackgroundColor:backgroundColor];
    }
    // 去掉TabBar上面黑线
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarWhetherToshowTopBlackLine)]) {
        if (NO == [self.tabBarDataSource tabBarWhetherToshowTopBlackLine]) {
            
            UIImage *clearImg = [UIImage imageWithColor:LZClearColor size:CGSizeMake(1.0, 1.0)];
            if (@available(iOS 13.0, *)) {
                
                UITabBarAppearance *appearance = self.tabBar.standardAppearance;
                appearance.shadowColor = LZClearColor;
                appearance.shadowImage = clearImg;
                [[UITabBar appearance] setStandardAppearance:appearance];
            } else {
                [[UITabBar appearance] setShadowImage:clearImg];
            }
        } else {
            
            UIColor *lineColor = UIColor.lightGrayColor;
            if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
                [self.tabBarDataSource respondsToSelector:@selector(tabBarTopBlackLineColor:)]) {
                lineColor = [self.tabBarDataSource tabBarTopBlackLineColor:self.myTabBar];
            }
            UIImage *lineImg = [UIImage imageWithColor:lineColor size:CGSizeMake(1.0, 0.6f)];
            if (@available(iOS 13.0, *)) {
            
                UITabBarAppearance *appearance = self.tabBar.standardAppearance;
                appearance.shadowColor = lineColor;
                appearance.shadowImage = lineImg;
                [[UITabBar appearance] setStandardAppearance:appearance];
            } else {
                [[UITabBar appearance] setShadowImage:lineImg];
            }
        }
        // 添加的图片大小不匹配的话，加上此句，屏蔽掉tabbar多余部分
        //         [UITabBar appearance].clipsToBounds = YES;
    }
    // 加号按钮偏移量
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarPlusBtnOffsetY:)]) {
        
        CGFloat offsetY = [self.tabBarDataSource tabBarPlusBtnOffsetY:self.myTabBar];
        self.myTabBar.plusBtnOffsetY = offsetY;
    }
    // TabBarBtn点击事件
    @lzweakify(self);
    self.myTabBar.tabBarBtnDidClickBlock = ^(LZTabBar *myTabBar, NSInteger from, NSInteger to) {
        @lzstrongify(self);
        if ([self conformsToProtocol:@protocol(LZTabBarControllerDelegate)] &&
            [self.tabBarDelegate respondsToSelector:@selector(tabBarBtnDidClick:from:to:)]) {
            [self.tabBarDelegate tabBarBtnDidClick:myTabBar from:from to:to];
        }
    };
    // 加号按钮点击事件
    self.myTabBar.tabBarPulsBtnDidClickBlock = ^(LZTabBar *myTabBar) {
        @lzstrongify(self);
        if ([self conformsToProtocol:@protocol(LZTabBarControllerDelegate)] &&
            [self.tabBarDelegate respondsToSelector:@selector(plusBtnDidCilck:)]) {
            [self.tabBarDelegate plusBtnDidCilck:myTabBar];
        }
    };
    // TabBar 默认选中
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDelegate)] &&
        [self.tabBarDelegate respondsToSelector:@selector(tabBarDefaultSelectedIndex:)]) {
        self.myTabBar.defaultSelectedIndex = [self.tabBarDelegate tabBarDefaultSelectedIndex:self.myTabBar];
    }
}

- (void)_removeSysTabarButton {
    [self.tabBar.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         if ([obj isKindOfClass:NSClassFromString(@"UITabBarButton")]) [obj removeFromSuperview];
     }];
}

- (UIViewController *)_configChildViewController:(UIViewController *)childViewController
                                           title:(NSString *)title
                                       normalImg:(UIImage *)normalImg
                                     selectedImg:(UIImage *)selectedImg {
    
    UIViewController *viewController = childViewController;
    if ([childViewController respondsToSelector:@selector(topViewController)]) {
        
        viewController = [(UINavigationController *)childViewController topViewController];
        if ([viewController isKindOfClass:NSClassFromString(@"RTContainerController")]) {
            
            SEL selector = NSSelectorFromString(@"contentViewController");
            if ([viewController respondsToSelector:selector]) {
                
                IMP imp = [viewController methodForSelector:selector];
                UIViewController * (*func)(id, SEL) = (void *)imp;
                viewController = func(viewController, selector);
            }
        }
    }
    viewController.title = title;
    viewController.tabBarItem.image = normalImg;
    if (UIImageRenderingModeAlwaysOriginal != selectedImg.renderingMode) {
        selectedImg = [selectedImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    viewController.tabBarItem.selectedImage = selectedImg;
    return viewController;
}

@end
