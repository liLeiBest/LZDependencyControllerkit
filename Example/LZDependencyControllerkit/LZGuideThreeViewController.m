//
//  LZGuideThreeViewController.m
//  Pods
//
//  Created by Dear.Q on 2019/9/18.
//

#import "LZGuideThreeViewController.h"

@interface LZGuideThreeViewController () {
	__weak IBOutlet UIImageView *bgImgView;
}

@end

@implementation LZGuideThreeViewController

// MARK: - Initialization
- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self setupUI];
}

// MARK: - Public
+ (instancetype)instance {
    
    NSString *identify = NSStringFromClass(self);
    return [self viewControllerFromstoryboard:identify inBundle:nil];
}

// MARK: - UI Action
- (IBAction)exprienceDidTouchDown:(id)sender {
	
	NSDictionary *userInfo = @{LZStartPageCloseNotificationTriggerKey : @(LZStartPageCloseTriggerEnter)};
	LZQuickUnit.notificationPost(LZStartPageDidCloseNotification, @(LZStartPageCloseTriggerEnter), userInfo);
}

// MARK: - Private
- (void)setupUI {
}

@end
