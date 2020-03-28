//
//  LZGuideTwoViewController.m
//  Pods
//
//  Created by Dear.Q on 2019/9/18.
//

#import "LZGuideTwoViewController.h"

@interface LZGuideTwoViewController () {
	__weak IBOutlet UIImageView *bgImgView;
}

@end

@implementation LZGuideTwoViewController

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

// MARK: - Private
- (void)setupUI {
}


@end
