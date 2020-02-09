//
//  LZViewController.m
//  LZDependencyControllerkit
//
//  Created by lilei_hapy@163.com on 07/13/2019.
//  Copyright (c) 2019 lilei_hapy@163.com. All rights reserved.
//

#import "LZViewController.h"
#import "LZDiscoverViewController.h"
#import "LZDiscoverDetailViewController.h"
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
    
    [self configTabController];
}

- (void)configTabController {
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [UIColor blackColor],
        NSFontAttributeName : [UIFont systemFontOfSize:13 weight:UIFontWeightThin],
    } forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [UIColor redColor],
        NSFontAttributeName : [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold],
    } forState:UIControlStateSelected];
    
    LZDiscoverDetailViewController *ctr = [[LZDiscoverDetailViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
    [self addChildViewController:nav title:@"测试" normalImg:nil selectedImg:nil];
    
    UIViewController *ctr1 = [[UIViewController alloc] init];
    ctr1.view.backgroundColor = [UIColor whiteColor];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:ctr1];
    UIImage *civilizationImg = [UIImage imageNamed:@"apple-worm"];
    [self addChildViewController:nav1 title:nil normalImg:civilizationImg selectedImg:civilizationImg];
    
    LZTestViewController *ctr2 = [[LZTestViewController alloc] init];
    ctr2.view.backgroundColor = [UIColor orangeColor];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:ctr2];
    UIImage *wormImg = [UIImage imageNamed:@"apple-worm"];
    [self addChildViewController:nav2 title:@"哈哈" normalImg:wormImg selectedImg:wormImg];
    
    LZDiscoverViewController *ctr3 = [[LZDiscoverViewController alloc] init];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:ctr3];
    UIImage *discoverImg = [UIImage imageNamed:@"tab_civilization_icon"];
    [self addChildViewController:nav3 title:@"发现" normalImg:discoverImg selectedImg:discoverImg];
}

// MARK: - LZTabBarViewController
// MARK: <LZTabBarControllerDataSource>
//- (BOOL)tabBarWhetherToShowPlusBtn {
//    return YES;
//}
//
//- (NSDictionary *)tabBarPlusAttributes:(LZTabBar *)myTabBar {
//    return @{LZTabBarPlusBtnImage : [UIImage imageNamed:@"apple-worm"],
//    };
//}

- (NSDictionary *)tabBarBtnAttributes:(LZTabBar *)myTabBar {
    return @{LZTabBarTitleNormalColor : [UIColor blackColor],
             LZTabBarTitleSelectedColor : [UIColor redColor],
             LZTabBarTitleFont : [UIFont systemFontOfSize:16],
    };
}

- (UIColor *)tabBarBackgroundColor:(LZTabBar *)myTabBar {
    return [UIColor whiteColor];
}

- (UIImage *)tabBarBackgroundImage:(LZTabBar *)myTabBar {
    return [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 10)];
}

- (BOOL)tabBarWhetherToshowTopBlackLine {
    return NO;
}

// MARK: <LZTabBarControllerDelegate>
- (void)tabBarBtnDidClick:(LZTabBar *)myTabBar
                     from:(NSInteger)from
                       to:(NSInteger)to {
    
    if (from == to) {
        return;
    }
    self.selectedIndex = to;
    if (0 == to) {
        
        UINavigationController *nav = self.selectedViewController;
        nav.topViewController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", arc4random_uniform(100)];
    }
}

- (void)plusBtnDidCilck:(LZTabBar *)myTabBar {
    NSLog(@"=======");
}

- (NSUInteger)tabBarDefaultSelectedIndex:(LZTabBar *)myTabBar {
    return 1;
}

@end
