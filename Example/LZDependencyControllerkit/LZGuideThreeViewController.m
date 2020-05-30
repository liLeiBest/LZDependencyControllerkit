//
//  LZGuideThreeViewController.m
//  Pods
//
//  Created by Dear.Q on 2019/9/18.
//

#import "LZGuideThreeViewController.h"

@interface LZGuideThreeViewController () {
    IBOutlet UIImageView *bgImgView;
    IBOutlet UIButton *productBtn;
    IBOutlet UIButton *exprienceBtn;
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
    if (self.exprienceDidTouchCallback) {
        self.exprienceDidTouchCallback();
    }
}

- (IBAction)productManualDidTouchDown {
    
}

// MARK: - Private
- (void)setupUI {
    
    UIColor *titleColor = [UIColor whiteColor];
    UIColor *bgColor = [UIColor orangeColor];
    CGFloat corner = productBtn.frame.size.height * 0.5f;
    CGFloat borderW = 2.0f;
    [productBtn setTitleColor:titleColor forState:UIControlStateNormal];
    productBtn.backgroundColor = bgColor;
    productBtn.layer.borderColor = titleColor.CGColor;
    productBtn.layer.borderWidth = borderW;
    productBtn.layer.cornerRadius = corner;
   
    [exprienceBtn setTitleColor:titleColor forState:UIControlStateNormal];
    exprienceBtn.backgroundColor = bgColor;
    exprienceBtn.layer.borderColor = titleColor.CGColor;
    exprienceBtn.layer.borderWidth = borderW;
    exprienceBtn.layer.cornerRadius = corner;
}

@end
