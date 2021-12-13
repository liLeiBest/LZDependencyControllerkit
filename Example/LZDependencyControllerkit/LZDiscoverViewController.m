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

// MARK: - Initialization
- (void)loadView {
    [super loadView];
    
    [self setupUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
}

// MARK: - UI Action
- (void)leftDidClick {
    
    [self configURL];
}

- (void)rightDidClick {
    [self reloadRequest];
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
    
    self.showWebTitle = NO;
    self.displayRefresh = YES;
    self.mediaPlaybackRequiresUserAction = NO;
    __weak typeof(self) weakSelf = self;
    self.extractSubLinkCompletionHander = ^(NSURL *linkURL) {

        LZDiscoverDetailViewController *detail = [[LZDiscoverDetailViewController alloc] init];
        detail.urlString = linkURL.absoluteString;
        [weakSelf.navigationController pushViewController:detail animated:YES];
    };
    [self configURL];
}

- (void)configURL {
    
    self.customUserAgent = @"iPhone 24";
    NSString *urlString = @"https://www.baidu.com";
    NSURL *URL = [NSURL URLWithString:urlString];
    self.URL = URL;
}

@end
