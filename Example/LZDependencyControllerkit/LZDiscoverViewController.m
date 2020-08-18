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
    // @"https://www.baidu.com";
    // @"https://www.sina.cn";
    // @"http://cms.kids.andedu.net:8282/readydiscover/index.jhtml";
    // @"http://edu.10086.cn/customer-manage/H5/personalcenter/home_page?deviceId=&userId=1003138834885&extend=4R%2FvsM7tt69G9lBi5Kazea%2FDIPBGUJENlggudcITVS7I3lPmhiDeUZtJ6HigdjuMy73e3p8wYBXphuL3XnAYAw%3D%3D";
    // @"https://cmsapi.andedu.net:9005/index?access_token=llNJ3jZ3pCnHyDSLJGwxbkQPhMmtJSD5hDegtzkaBrtgZQgIC7sf4hQvCDw56dziN7jc8gvQamtERZbV45rXPw%253D%253D&current_user_id=36856056&parentId=2033770810&parentName=%E5%AE%B6%E9%95%BF&parentAvator=&parentBirthday=&parentGender=0&parentPhone=18867101623&parentAddress=(null)&studentId=1016991145&studentName=%E6%B1%AA%E7%8F%BA&studentAvatar=2b04df3ecc1d94afddff082d139c6f15&studentBirthday=2020-04-29&studentGender=0&classId=3819365&className=hangyan&schoolId=3019548&schoolName=%E5%92%8C%E5%AE%9D%E8%B4%9D%E5%B9%BC%E5%84%BF%E5%9B%AD&grade=4&status=1&enrolmentYear=0&province=120000&city=120100&county=120101&relation=%E6%AF%8D%E4%BA%B2&app_customization=120000&client_role=1&cms_version=1.0";
    NSString *urlString = @"http://101.200.135.215:19095/%E4%B8%8A%E5%AD%A6%E6%AD%8C.htm";
    NSURL *URL = [NSURL URLWithString:urlString];
    self.URL = URL;
}

@end
