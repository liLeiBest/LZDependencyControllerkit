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
- (instancetype)init {
    if (self = [super init]) {
        _showPlusBtn = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTabBar];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self removeSysTabarButton];
}

#pragma mark - Public
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    
    [self.myTabBar updateSelectedIndex:selectedIndex];
}

- (void)addChildViewController:(UIViewController *)childController
                         title:(NSString *)title
                     normalImg:(UIImage *)normalImg
                   selectedImg:(UIImage *)selectedImg {
    
	[self addChildViewController:childController];
	
	UIViewController *viewController = childController;
	if ([childController respondsToSelector:@selector(topViewController)]) {
        
		viewController = [(UINavigationController *)childController topViewController];
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
	[self.myTabBar addTabBarBtn:viewController.tabBarItem];
}

// MARK: - Private
- (void)setupTabBar {
    
    // 实例LZTabBar
    LZTabBar *tabBar = nil;
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarWhetherToShowPlusBtn)]) {
        self.showPlusBtn = [self.tabBarDataSource tabBarWhetherToShowPlusBtn];
    }
    if (self.isShowPlusBtn) {
        
        tabBar = [[LZTabBar alloc] initWithPlusBtn];
        tabBar.frame = self.tabBar.bounds;
    } else {
        tabBar = [[LZTabBar alloc] initWithFrame:self.tabBar.bounds];
    }
    self.myTabBar = tabBar;
    [self.tabBar addSubview:tabBar];
    
    // 设置TabBarButton
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarBtnAttributes:)]) {
        
        NSDictionary *attributes = [self.tabBarDataSource tabBarBtnAttributes:self.myTabBar];
        tabBar.tabBarBtnNormalColor = [attributes objectForKey:LZTabBarTitleNormalColor];
        tabBar.tabBarBtnSelectedColor = [attributes objectForKey:LZTabBarTitleSelectedColor];
        tabBar.tabBarBtnFont = [attributes objectForKey:LZTabBarTitleFont];
    }
    
    // 设置加号按钮
    if (self.isShowPlusBtn &&
        [self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarPlusAttributes:)]) {
        
        NSDictionary *plusAttributes = [self.tabBarDataSource tabBarPlusAttributes:self.myTabBar];
        [tabBar setupPlusBtnBackgroundImage:[plusAttributes objectForKey:LZTabBarPlusBtnBackgroundImage]
                                   forState:UIControlStateNormal];
        [tabBar setupPlusBtnImage:[plusAttributes objectForKey:LZTabBarPlusBtnImage]
                         forState:UIControlStateNormal];
        [tabBar setupPlusBtnAttributedTitle:[plusAttributes objectForKey:LZTabBarPlusBtnAttributedTitle]
                                   forState:UIControlStateNormal];
    }
    
    // TabBar背景
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarBackgroundImage:)]) {
        
        UIImage *backgroundImage =
        [[self.tabBarDataSource tabBarBackgroundImage:self.myTabBar] middleStretch];
        [[UITabBar appearance] setBackgroundImage:backgroundImage];
    }
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarBackgroundColor:)]) {
        
        UIColor *backgroundColor = [self.tabBarDataSource tabBarBackgroundColor:self.myTabBar];
        [[UITabBar appearance] setBarTintColor:backgroundColor];
    }
    
    // 去掉TabBar上面黑线
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarWhetherToshowTopBlackLine)]) {
        
        UIImage *clearImage =
        [UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(1.0, 1.0)];
        if (![self.tabBarDataSource respondsToSelector:@selector(tabBarBackgroundImage:)] &&
            ![self.tabBarDataSource respondsToSelector:@selector(tabBarBackgroundColor:)]) {
            [[UITabBar appearance] setBackgroundImage:clearImage];
        }
        [[UITabBar appearance] setShadowImage:clearImage];
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
    __weak typeof(self) weakSelf = self;
    tabBar.tabBarBtnDidClickBlock = ^(LZTabBar *myTabBar, NSInteger from, NSInteger to) {
        if ([weakSelf conformsToProtocol:@protocol(LZTabBarControllerDelegate)] &&
            [weakSelf.tabBarDelegate respondsToSelector:@selector(tabBarBtnDidClick:from:to:)]) {
            [weakSelf.tabBarDelegate tabBarBtnDidClick:myTabBar from:from to:to];
        }
    };
    
    // 加号按钮点击事件
    tabBar.tabBarPulsBtnDidClickBlock = ^(LZTabBar *myTabBar) {
        if ([weakSelf conformsToProtocol:@protocol(LZTabBarControllerDelegate)] &&
            [weakSelf.tabBarDelegate respondsToSelector:@selector(plusBtnDidCilck:)]) {
            [weakSelf.tabBarDelegate plusBtnDidCilck:myTabBar];
        }
    };
    
    // TabBar 默认选中
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDelegate)] &&
        [self.tabBarDelegate respondsToSelector:@selector(tabBarDefaultSelectedIndex:)]) {
        tabBar.defaultSelectedIndex = [self.tabBarDelegate tabBarDefaultSelectedIndex:tabBar];
    }
}

- (void)removeSysTabarButton {
    [self.tabBar.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         if ([obj isKindOfClass:NSClassFromString(@"UITabBarButton")]) [obj removeFromSuperview];
     }];
}

@end
