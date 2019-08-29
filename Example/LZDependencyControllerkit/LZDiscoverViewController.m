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
	
	NSString *urlString = @"http://cms.kids.andedu.net:8282/readydiscover/index.jhtml";
    NSURL *URL = [NSURL URLWithString:urlString];
    self.URL = URL;
	self.rotationLandscape = YES;
    __weak typeof(self) weakSelf = self;
    self.extractSubLinkCompletionHander = ^(NSURL *linkURL)
    {
        LZDiscoverDetailViewController *detail = [[LZDiscoverDetailViewController alloc] init];
        detail.URL = linkURL;
        [weakSelf.navigationController pushViewController:detail animated:YES];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
