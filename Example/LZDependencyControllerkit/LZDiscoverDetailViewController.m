//
//  LZDiscoverDetailViewController.m
//  LZDependencyControllerkit
//
//  Created by Dear.Q on 2017/4/8.
//  Copyright © 2017年 lilei_hapy@163.com. All rights reserved.
//

#import "LZDiscoverDetailViewController.h"

@interface LZDiscoverDetailViewController ()

@end

@implementation LZDiscoverDetailViewController

- (void)loadView {
    [super loadView];
    
    self.navBackIcon = [UIImage imageNamed:@"nav_icon_back_black"];
    self.navCloseIcon = [UIImage imageNamed:@"nav_icon_close_black"];
    __weak typeof(self) weakSelf = self;
    self.extractSubLinkCompletionHander = ^(NSURL *linkURL) {

        LZDiscoverDetailViewController *detail = [[LZDiscoverDetailViewController alloc] init];
        detail.URL = linkURL;
        [weakSelf.navigationController pushViewController:detail animated:YES];
    };
}

@end
