//
//  LZViewController.m
//  LZDependencyControllerkit
//
//  Created by lilei_hapy@163.com on 07/13/2019.
//  Copyright (c) 2019 lilei_hapy@163.com. All rights reserved.
//

#import "LZViewController.h"
#import "LZDiscoverViewController.h"
#import "LZTestWebJSViewController.h"
#import "LZTestViewController.h"

@interface LZViewController ()<LZTabBarControllerDataSource, LZTabBarControllerDelegate>

@end

@implementation LZViewController

// MARK: - Initialization
- (void)loadView {
    [super loadView];
    
    self.tabBarDataSource = self;
    self.tabBarDelegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

//MARK: - Private
- (void)setupUI {
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.tabBar.backgroundColor = UIColor.whiteColor;
    [[UITabBarItem appearance] setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [UIColor blackColor],
        NSFontAttributeName : [UIFont systemFontOfSize:10 weight:UIFontWeightThin],
    } forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [UIColor redColor],
        NSFontAttributeName : [UIFont systemFontOfSize:10 weight:UIFontWeightSemibold],
    } forState:UIControlStateSelected];
    [self configTabController];
}

- (void)configTabController {
    
    LZTestViewController *ctr = [[LZTestViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
    [self addChildViewController:nav title:@"测试" normalImg:nil selectedImg:nil];
    
    UIViewController *ctr1 = [[UIViewController alloc] init];
    ctr1.view.backgroundColor = [UIColor whiteColor];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:ctr1];
    UIImage *civilizationImg = [UIImage imageNamed:@"apple-worm"];
    [self addChildViewController:nav1 title:nil normalImg:civilizationImg selectedImg:civilizationImg];
    ctr1.title = @"无标题";
    
    LZTestWebJSViewController *ctr2 = [[LZTestWebJSViewController alloc] init];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:ctr2];
    UIImage *norImg = [UIImage imageNamed:@"tabbar_classroom_default"];
    UIImage *selImg = [UIImage imageNamed:@"tabbar_classroom_selected"];
    [self addChildViewController:nav2 title:@"" normalImg:norImg selectedImg:selImg];
    
    LZDiscoverViewController *ctr3 = [[LZDiscoverViewController alloc] init];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:ctr3];
    [self addChildViewController:nav3 title:@"发现" normalImg:norImg selectedImg:selImg];
}

// MARK: - LZTabBarViewController
// MARK: <LZTabBarControllerDataSource>
//- (NSDictionary *)tabBarBtnAttributes:(LZTabBar *)myTabBar {
//    return @{LZTabBarTitleNormalColor : [UIColor blackColor],
//             LZTabBarTitleSelectedColor : [UIColor redColor],
//             LZTabBarTitleFont : [UIFont systemFontOfSize:16],
//    };
//}

- (UIColor *)tabBarBackgroundColor:(LZTabBar *)myTabBar {
    return [UIColor whiteColor];
}

//- (UIImage *)tabBarBackgroundImage:(LZTabBar *)myTabBar {
//    return [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 10)];
//}

// MARK: <LZTabBarControllerDelegate>
- (void)tabBarBtnDidClick:(LZTabBar *)myTabBar
                     from:(NSInteger)from
                       to:(NSInteger)to {
    
    if (from == to) {
        return;
    }
    self.selectedIndex = to;
    if (0 == to) {
        // 角标
        UINavigationController *nav = self.selectedViewController;
        nav.topViewController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", arc4random_uniform(100)];
    } else if (1 == to) {
        
        [self setViewControllers:@[] animated:NO];
        [self configTabController];
    } else if (2 == to) {
        
    } else if (3 == to) {
        
        LZWebViewController *ctr1 = [[LZWebViewController alloc] init];
        ctr1.URL = [NSURL URLWithString:@"https://www.baidu.com"];
        ctr1.showWebTitle = NO;
        @lzweakify(self);
        ctr1.extractSubLinkCompletionHander = ^(NSURL *linkURL) {
            @lzstrongify(self);
            LZWebViewController *ctr1 = [[LZWebViewController alloc] init];
            ctr1.URL = linkURL;
            [(UINavigationController *)self.selectedViewController pushViewController:ctr1 animated:YES];
        };
        UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:ctr1];
        UIImage *norImg = [UIImage imageNamed:@"tabbar_classroom_default"];
        UIImage *selImg = [UIImage imageNamed:@"tabbar_classroom_selected"];
        [self updateChildViewController:nav1 index:3 title:@"更新视图" normalImg:norImg selectedImg:selImg];
    }
}

- (NSUInteger)tabBarDefaultSelectedIndex:(LZTabBar *)myTabBar {
    return 0;
}

@end
