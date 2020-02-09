//
//  LZDiscoverViewController.m
//  LZDependencyControllerkit
//
//  Created by Dear.Q on 2017/4/7.
//  Copyright © 2017年 lilei_hapy@163.com. All rights reserved.
//

#import "LZDiscoverViewController.h"
#import "LZDiscoverDetailViewController.h"

@interface LZDiscoverViewController ()

@end

@implementation LZDiscoverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self setupUI];
}

// MARK: - UI Action
// MARK: - UI Action
- (void)leftDidClick {
    
}

- (void)rightDidClick {
    [self reload];
}

// MARK: - Private
- (void)setupUI {
    
    [self configNavItem];
    [self configWebView];
}

- (void)configNavItem {
    
    self.navigationItem.leftBarButtonItem =
    [UIBarButtonItem itemWithTitle:@"左" target:self action:@selector(leftDidClick)];
    NSDictionary *titleAttrs = @{NSForegroundColorAttributeName : [UIColor redColor]};
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:titleAttrs
                                                         forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem =
    [UIBarButtonItem itemWithTitle:@"右" target:self action:@selector(rightDidClick)];
    titleAttrs = @{NSForegroundColorAttributeName : [UIColor orangeColor]};
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:titleAttrs
                                                          forState:UIControlStateNormal];
}

- (void)configWebView {
    
    NSString *urlString = @"http://cms.kids.andedu.net:8282/readydiscover/index.jhtml";
    NSURL *URL = [NSURL URLWithString:urlString];
    self.URL = URL;
    self.rotationLandscape = NO;
    self.showWebTitle = NO;
    __weak typeof(self) weakSelf = self;
    self.extractSubLinkCompletionHander = ^(NSURL *linkURL) {
        
        LZDiscoverDetailViewController *detail = [[LZDiscoverDetailViewController alloc] init];
        detail.URL = linkURL;
        [weakSelf.navigationController pushViewController:detail animated:YES];
    };
}

@end
