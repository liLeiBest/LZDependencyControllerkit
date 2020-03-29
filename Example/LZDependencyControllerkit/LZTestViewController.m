//
//  LZTestViewController.m
//  LZDependencyControllerkit_Example
//
//  Created by Dear.Q on 2020/2/9.
//  Copyright © 2020 lilei_hapy@163.com. All rights reserved.
//

#import "LZTestViewController.h"
#import "LZGuideOneViewController.h"
#import "LZGuideTwoViewController.h"
#import "LZGuideThreeViewController.h"

@interface LZTestViewController ()<LZGuidePageDelegate, LZAdvertisingPageDelegate>

@end

@implementation LZTestViewController

// MARK: - Initialization
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (LZGuideViewController.needGuide()) {
        
        LZGuideOneViewController *one = [LZGuideOneViewController instance];
        LZGuideTwoViewController *two = [LZGuideTwoViewController instance];
        LZGuideThreeViewController *three = [LZGuideThreeViewController instance];
        LZGuideViewController *ctr = LZGuideViewController
        .instance()
        .delegate(self)
        .guideViewControllers(@[one, two, three])
        .showTheEntranceControl(NO)
        .showPageControl(NO);
        ctr.modalPresentationStyle = UIModalPresentationFullScreen;
        ctr.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:ctr animated:YES completion:nil];
    }
}

// MARK: - UI Action
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    LZAdvertisingViewController *ctr =
    LZAdvertisingViewController.instance()
    .delegate(self)
    .skipWaitSeconds(5)
    .skipTitlel(@"广告");
    ctr.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:ctr animated:YES completion:nil];
}

// MARK: - Private
- (void)setupUI {
    
    self.view.backgroundColor = [UIColor lightGrayColor];
}

// MARK: - Delegate
// MARK: <LZGuidePageDelegate>
- (void)guideViewController:(LZGuideViewController *)guideViewController
               currentIndex:(NSUInteger)currentIndex
            didCloseTrigger:(LZStartPageCloseTrigger)closeTrigger {
    
    NSLog(@"当前第 %@ 页", LZQuickUnit.toString(@(currentIndex)));
    switch (closeTrigger) {
        case LZStartPageCloseTriggerSkip:
            NSLog(@"点击了跳过");
            break;
        case LZStartPageCloseTriggerEnter:
            NSLog(@"点击了查看详情");
            break;
        default:
            NSLog(@"点击了未知");
            break;
    }
}

// MARK: <LZAdvertisingPageDelegate>
- (void)advertisingViewController:(LZAdvertisingViewController *)advertisingViewController
                  didCloseTrigger:(LZStartPageCloseTrigger)closeTrigger {
    switch (closeTrigger) {
        case LZStartPageCloseTriggerSkip:
            NSLog(@"点击了跳过");
            break;
        case LZStartPageCloseTriggerEnter:
            NSLog(@"点击了查看详情");
            LZGuideViewController.clearTrigger();
            break;
        default:
            NSLog(@"点击了未知");
            break;
    }
}
- (NSURL *)advertisingViewControllerForCoverAd:(LZAdvertisingViewController *)advertisingViewController {
    
    NSString *imgURLString = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1585452528893&di=95442a108d60a388c924d815fa6cba7a&imgtype=0&src=http%3A%2F%2Fwww.318art.cn%2Fdata%2Fattached%2Fimage%2F20130326%2F20130326170226_93408.jpg";
    NSURL *imgURL = [NSURL URLWithString:imgURLString];
    return imgURL;
    NSString *imgFilePath = [[NSBundle mainBundle] pathForResource:@"5" ofType:@"jpg"];
    NSURL *fileFileURL = [NSURL fileURLWithPath:imgFilePath];
    return fileFileURL;
}

@end
