//
//  LZViewController.m
//  LZDependencyControllerkit
//
//  Created by lilei_hapy@163.com on 07/13/2019.
//  Copyright (c) 2019 lilei_hapy@163.com. All rights reserved.
//

#import "LZViewController.h"
#import "LZDiscoverViewController.h"

@interface LZViewController ()

@end

@implementation LZViewController

// MARK: - Initialization
- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self setupNavItem];
}

//MARK: - Private
- (void)setupNavItem {
	
	self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTitle:@"左" target:self action:@selector(leftDidClick)];
	[self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]}
														 forState:UIControlStateNormal];
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTitle:@"右" target:self action:@selector(rightDidClick)];
	[self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor orangeColor]}
														  forState:UIControlStateNormal];
}

- (void)leftDidClick {
	
}

- (void)rightDidClick {
	[self testWKWebView];
}

- (void)testWKWebView {
	
	LZDiscoverViewController *ctr = [[LZDiscoverViewController alloc] init];
	[self.navigationController pushViewController:ctr animated:YES];
}

@end
