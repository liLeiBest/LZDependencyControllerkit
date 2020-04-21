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
    
    [self configURL];
    self.rotationLandscape = NO;
    self.showWebTitle = NO;
    self.displayRefresh = YES;
    __weak typeof(self) weakSelf = self;
    self.extractSubLinkCompletionHander = ^(NSURL *linkURL) {

        LZDiscoverDetailViewController *detail = [[LZDiscoverDetailViewController alloc] init];
        detail.URL = linkURL;
        [weakSelf.navigationController pushViewController:detail animated:YES];
    };
}

- (void)configURL {
    
    self.customUserAgent = @"iPhone 24";
    // @"https://www.baidu.com";
    // @"https://www.sina.cn";
    // @"http://cms.kids.andedu.net:8282/readydiscover/index.jhtml";
    NSString *urlString = @"http://edu.10086.cn/customer-manage/H5/personalcenter/home_page?deviceId=&userId=1003138834885&extend=4R%2FvsM7tt69G9lBi5Kazea%2FDIPBGUJENlggudcITVS7I3lPmhiDeUZtJ6HigdjuMy73e3p8wYBXphuL3XnAYAw%3D%3D";
    NSURL *URL = [NSURL URLWithString:urlString];
    self.URL = URL;
    self.decidePolicyHandler = ^(WKNavigationAction *navigationAction, void (^decisionHandler)(WKNavigationActionPolicy navigationActionPolicy)) {

        NSURL *URL = navigationAction.request.URL;
        if ([URL.scheme isEqualToString:@"tel"]) {
            
//            NSString *resourceSpecifier = [URL resourceSpecifier];
//            NSString *callPhone = [NSString stringWithFormat:@"telprompt://%@", resourceSpecifier];
            /// 防止iOS 10及其之后，拨打电话系统弹出框延迟出现
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone]];
//            });
            if (@available(iOS 10, *)) {
                [[UIApplication sharedApplication] openURL:URL options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @(NO)} completionHandler:^(BOOL success) {
                }];
            } else {
                [[UIApplication sharedApplication] openURL:URL];
            }
            decisionHandler(WKNavigationActionPolicyCancel);
        } else {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    };
}

@end
