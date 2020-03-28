//
//  LZGuideOneViewController.m
//  Pods
//
//  Created by Dear.Q on 2019/9/18.
//

#import "LZGuideOneViewController.h"

@interface LZGuideOneViewController () {
	__weak IBOutlet UIImageView *bgImgView;
}

@end

@implementation LZGuideOneViewController

// MARK: - Initialization
- (void)viewDidLoad {
	[super viewDidLoad];
	
}

// MARK: - Public
+ (instancetype)instance {
    
    NSString *identify = NSStringFromClass(self);
    return [self viewControllerFromstoryboard:identify inBundle:nil];
}

// MARK: - Private
- (void)setupUI {
	bgImgView.image = [self image:@"guide_bg_one" inBundle:nil];
}

@end
