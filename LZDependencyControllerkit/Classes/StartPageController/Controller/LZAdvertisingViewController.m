//
//  LZAdvertisingViewController.m
//  Pods
//
//  Created by Dear.Q on 2019/9/18.
//

#import "LZAdvertisingViewController.h"
#import <SDWebImage/SDWebImage.h>

/** 最长等待时间，单位：秒 */
static NSUInteger MAX_WAIT_SECOND = 3;

@interface LZAdvertisingViewController () {
    
    id<LZAdvertisingPageDelegate> _delegate;
    
    BOOL _showSkipControl;
    NSUInteger _skipWaitSeconds;
    NSString *_skipTitle;
    UIColor *_skipTitleColor;
    UIColor *_skipBGColor;
}

@property (nonatomic, weak) IBOutlet UIButton *skipBtn;
@property (nonatomic, weak) IBOutlet UIImageView *advertisingBgImgView;

@property (strong, nonatomic) LZWeakTimer *timer;

@end

@implementation LZAdvertisingViewController

// MARK: - Initialization
- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setupDefaultValue];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateAllControlAppearence];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self cutdownSecond];
}

- (void)dealloc {
	LZLog();
}

// MARK: - Public
+ (LZAdvertisingViewController * _Nonnull (^)(void))instance {
    return ^id {
        return [self viewControllerFromstoryboard:NSStringFromClass(self)
                                         inBundle:@"LZStartPageController"];
    };
}

- (LZAdvertisingViewController * _Nonnull (^)(id<LZAdvertisingPageDelegate> _Nonnull))delegate {
    return ^id (id<LZAdvertisingPageDelegate> delegate) {
        self->_delegate = delegate;
        return self;
    };
}

- (LZAdvertisingViewController * _Nonnull (^)(void))defaultConfig {
    return ^id {
        return self;
    };
}

- (LZAdvertisingViewController * _Nonnull (^)(void))updateAppearance {
    return ^id {
        [self updateAllControlAppearence];
        return self;
    };
}

- (LZAdvertisingViewController * _Nonnull (^)(BOOL))showSkipControl {
    return ^id (BOOL showSkipControl) {
        self->_showSkipControl = showSkipControl;
        return self;
    };
}

- (LZAdvertisingViewController * _Nonnull (^)(NSUInteger))skipWaitSeconds {
    return ^id (NSUInteger skipWaitSeconds) {
        self->_skipWaitSeconds = skipWaitSeconds;
        return self;
    };
}

- (LZAdvertisingViewController * _Nonnull (^)(NSString * _Nonnull))skipTitlel {
    return ^id (NSString * skipTitlel) {
        self->_skipTitle = skipTitlel;
        return self;
    };
}

- (LZAdvertisingViewController * _Nonnull (^)(UIColor * _Nonnull))skipTitleColor {
    return ^id (UIColor * skipTitleColor) {
        self->_skipTitleColor = skipTitleColor;
        return self;
    };
}

- (LZAdvertisingViewController * _Nonnull (^)(UIColor * _Nonnull))skipBGColor {
    return ^id (UIColor * skipBGColor) {
        self->_skipBGColor = skipBGColor;
        return self;
    };
}

// MARK: - UI Action
- (IBAction)skipDidTouchDown:(id)sender {
	[self closedByTrigger:LZStartPageCloseTriggerSkip];
}

- (IBAction)detailDidSingleTap:(id)sender {
	[self closedByTrigger:LZStartPageCloseTriggerEnter];
}

// MARK: - Private
- (void)setupDefaultValue {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    id value = self
    .showSkipControl(YES)
    .skipWaitSeconds(MAX_WAIT_SECOND)
    .skipTitlel(@"跳过")
    .skipTitleColor([UIColor blackColor])
    .skipBGColor([UIColor colorWithHexString:@"#DAEEFF"]);
#pragma clang diagnostic pop
}

- (void)setupUI {
	
	[self configSkipBtn];
	[self configCoverAd];
}

- (void)configSkipBtn {
	
	self.skipBtn.layer.cornerRadius = self.skipBtn.height * 0.5f;
    self.skipBtn.layer.masksToBounds = YES;
	[self.view bringSubviewToFront:self.skipBtn];
}

- (void)configCoverAd {
	
	SEL selector = @selector(advertisingViewControllerForCoverAd:);
	if ([self->_delegate respondsToSelector:selector]) {
		
		NSURL *imgURL = [self->_delegate advertisingViewControllerForCoverAd:self];
		[self.advertisingBgImgView  sd_setImageWithURL:imgURL
                                      placeholderImage:nil
                                               options:SDWebImageRefreshCached];
	}
}

- (void)updateAllControlAppearence {
    
    self.skipBtn.hidden = !self->_showSkipControl;
    if (self->_showSkipControl) {
        
        [self updateSkipTitle:self->_skipWaitSeconds];
        [self.skipBtn setTitleColor:self->_skipTitleColor forState:UIControlStateNormal];
        [self.skipBtn setBackgroundColor:self->_skipBGColor];
    }
}

- (void)cutdownSecond {
    
    __block NSInteger cumulativeSseconds = 1;
    dispatch_queue_t queue = dispatch_get_main_queue();
    @lzweakify(self);
    self.timer =
    [LZWeakTimer scheduledTimerWithTimeInterval:1.0 repeats:YES dispatchQueue:queue eventHandler:^{
        @lzstrongify(self);
        NSInteger remainingSeconds = self->_skipWaitSeconds - cumulativeSseconds;
        [self updateSkipTitle:remainingSeconds];
        cumulativeSseconds++;
        if (0 >= remainingSeconds) {
            
            [self.timer invalidate];
            [self closedByTrigger:LZStartPageCloseTriggerSkip];
        }
    }];
}

- (void)updateSkipTitle:(NSUInteger)remainingSeconds {
    
    NSString *title =
    [NSString stringWithFormat:@"%@(%@秒)",
     self->_skipTitle,
     LZQuickUnit.toString(@(remainingSeconds))];
    [self.skipBtn setTitle:title forState:UIControlStateNormal];
}

- (void)closedByTrigger:(LZStartPageCloseTrigger)trigger {
    
    [self dismiss];
    SEL selector = @selector(advertisingViewController:didCloseTrigger:);
    if ([self->_delegate respondsToSelector:selector]) {
        [self->_delegate advertisingViewController:self didCloseTrigger:trigger];
    }
}

@end
