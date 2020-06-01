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
    self.displayRefresh = NO;
    self.disappearToRefresh = YES;
    self.allowsInlineMediaPlayback = YES;
    self.mediaPlaybackRequiresUserAction = YES;
    self.rotationLandscape = YES;
    __weak typeof(self) weakSelf = self;
    self.extractSubLinkCompletionHander = ^(NSURL *linkURL) {

        LZDiscoverDetailViewController *detail = [[LZDiscoverDetailViewController alloc] init];
        detail.urlString = linkURL.absoluteString;
        [weakSelf.navigationController pushViewController:detail animated:YES];
    };
    self.URL = [NSURL URLWithString:self.urlString];
}

@end
