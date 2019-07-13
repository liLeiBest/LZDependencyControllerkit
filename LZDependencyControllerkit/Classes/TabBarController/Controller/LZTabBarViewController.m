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

#pragma mark - init
- (instancetype)init
{
    if (self = [super init])
    {    
        _showPlusBtn = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTabBar];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self removeSysTabarButton];
}

/** Setter */
- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    
    [self.myTabBar updateSelectedIndex:selectedIndex];
}

#pragma mark - Public
/** 添加子控制器 */
- (void)addChildViewController:(UIViewController *)childController
                         title:(NSString *)title
                     normalImg:(NSString *)normalImg
                   selectedImg:(NSString *)selectedImg
{
	[self addChildViewController:childController];
	
	UIViewController *viewController = childController;
	if ([childController respondsToSelector:@selector(topViewController)])
	{
		viewController = [(UINavigationController *)childController topViewController];
	}
	
	viewController.title = title;
	viewController.tabBarItem.image = [UIImage imageNamed:normalImg];
	UIImage *selectedImage = [UIImage imageNamed:selectedImg];
	selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	viewController.tabBarItem.selectedImage = selectedImage;
	[self.myTabBar addTabBarBtn:viewController.tabBarItem];
}

#pragma mark - Private
/**
 @author Lilei
 
 @brief 设置TabBar
 */
- (void)setupTabBar
{
    // 实例LZTabBar
    LZTabBar *tabBar = nil;
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarWhetherToShowPlusBtn)])
    {
        self.showPlusBtn = [self.tabBarDataSource tabBarWhetherToShowPlusBtn];
    }
    if (self.isShowPlusBtn)
    {
        tabBar = [[LZTabBar alloc] initWithPlusBtn];
        tabBar.frame = self.tabBar.bounds;
    }
    else
    {
        tabBar = [[LZTabBar alloc] initWithFrame:self.tabBar.bounds];
    }
    self.myTabBar = tabBar;
    
    // 设置TabBarButton
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarBtnAttributes:)])
    {
        NSDictionary *attributes = [self.tabBarDataSource tabBarBtnAttributes:self.myTabBar];
        tabBar.tabBarBtnNormalColor = [attributes objectForKey:LZTabBarTitleNormalColor];
        tabBar.tabBarBtnSelectedColor = [attributes objectForKey:LZTabBarTitleSelectedColor];
        tabBar.tabBarBtnFont = [attributes objectForKey:LZTabBarTitleFont];
    }
    
    // 设置加号按钮
    if (self.isShowPlusBtn &&
        [self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarPlusAttributes:)])
    {
        NSDictionary *plusAttributes = [self.tabBarDataSource tabBarPlusAttributes:self.myTabBar];
        [tabBar setupPlusBtnBackgroundImage:[plusAttributes objectForKey:LZTabBarPlusBtnBackgroundImage]
                                   forState:UIControlStateNormal];
        [tabBar setupPlusBtnBackgroundImage:[plusAttributes objectForKey:LZTabBarPlusBtnBackgroundImage]
                                   forState:UIControlStateHighlighted];
        [tabBar setupPlusBtnImage:[plusAttributes objectForKey:LZTabBarPlusBtnImage]
                         forState:UIControlStateNormal];
        [tabBar setupPlusBtnImage:[plusAttributes objectForKey:LZTabBarPlusBtnImage]
                         forState:UIControlStateHighlighted];
        [tabBar setupPlusBtnAttributedTitle:[plusAttributes objectForKey:LZTabBarPlusBtnAttributedTitle]
                                   forState:UIControlStateNormal];
    }
    
    // TabBarBtn点击事件
    __weak typeof(self) weakSelf = self;
    tabBar.tabBarBtnDidClickBlock = ^(LZTabBar *myTabBar,
                                      NSInteger from,
                                      NSInteger to)
    {
        if ([weakSelf conformsToProtocol:@protocol(LZTabBarControllerDelegate)] &&
            [weakSelf.tabBarDelegate respondsToSelector:@selector(tabBarBtnDidClick:from:to:)])
        {
            [weakSelf.tabBarDelegate tabBarBtnDidClick:myTabBar
                                            from:from
                                              to:to];
        }
    };
    
    // 加号按钮点击事件
    tabBar.tabBarPulsBtnDidClickBlock = ^(LZTabBar *myTabBar)
    {
        if ([weakSelf conformsToProtocol:@protocol(LZTabBarControllerDelegate)] &&
            [weakSelf.tabBarDelegate respondsToSelector:@selector(plusBtnDidCilck:)])
        {
            [weakSelf.tabBarDelegate plusBtnDidCilck:myTabBar];
        }
    };
    [self.tabBar addSubview:tabBar];
    
    // TabBar 背景
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarBackgroundImage:)])
    {
        UIImage *backgroundImage = [[self.tabBarDataSource tabBarBackgroundImage:self.myTabBar] middleStretch];
        [self.tabBar setBackgroundImage:backgroundImage];
    }
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarBackgroundColor:)])
    {
        UIColor *backgroundColor = [self.tabBarDataSource tabBarBackgroundColor:self.myTabBar];
        [self.tabBar setBackgroundColor:backgroundColor];
        UIImage *backgroundImage = [UIImage imageWithColor:backgroundColor
                                                      size:CGSizeMake(self.view.frame.size.width, 1.0)];
        [self.tabBar setBackgroundImage:backgroundImage];
    }
    
    // 去掉TabBar上面黑线
    if ([self conformsToProtocol:@protocol(LZTabBarControllerDataSource)] &&
        [self.tabBarDataSource respondsToSelector:@selector(tabBarWhetherToshowTopBlackLine)])
    {
        UIImage *clearImage = [UIImage imageWithColor:[UIColor clearColor]
                                                 size:CGSizeMake(self.view.frame.size.width, 1.0)];
        if (![self.tabBarDataSource respondsToSelector:@selector(tabBarBackgroundImage:)] &&
            ![self.tabBarDataSource respondsToSelector:@selector(tabBarBackgroundColor:)])
            [self.tabBar setBackgroundImage:clearImage];
        [self.tabBar setShadowImage:clearImage];
    }
}

/**
 @author Lilei
 
 @brief 移除系统TabBarBtn
 */
- (void)removeSysTabarButton
{
    [self.tabBar.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:NSClassFromString(@"UITabBarButton")]) [obj removeFromSuperview];
     }];
}

@end
