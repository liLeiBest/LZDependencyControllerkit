//
//  LZGuideViewController.m
//  Pods
//
//  Created by Dear.Q on 2019/9/18.
//

#import "LZGuideViewController.h"
#import <LZDependencyToolkit/LZDependencyToolkit.h>

NSNotificationName const LZStartPageDidCloseNotification = @"LZStartPageDidCloseNotification";
LZStartPageNotificationKey const LZStartPageCloseNotificationTriggerKey = @"LZStartPageCloseNotificationTriggerKey";
/** 记录引导页显示的版本 */
static NSString * const LZGuidePageShowInVersionKey = @"LZGuidePageShowInVersionKey";

@interface LZGuideViewController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource> {
    
    id<LZGuidePageDelegate> _delegate;
    
    BOOL _showSkipControl;
    NSString *_skipTitle;
    UIColor *_skipTitleColor;
    UIColor *_skipBGColor;

    BOOL _showPageControl;
    UIColor *_pageColor;
    UIColor *_currentPageColor;

    BOOL _showTheEntranceControl;
    NSString *_theEntranceTitle;
    UIColor *_theEntranceTitleColor;
    UIColor *_theEntranceBGColor;
    UIColor *_theEntranceBorderColor;
    
    BOOL _infiniteScrolling;
}

@property (nonatomic, weak) IBOutlet UIButton *skipBtn;
@property (nonatomic, weak) IBOutlet UIButton *exprienceBtn;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray *guideControllers;
@property (assign, nonatomic) NSUInteger currentIndex;
@property (strong, nonatomic) UIViewController *currentViewController;

@end

@implementation LZGuideViewController

// MARK: - Lazy Loading
- (UIPageViewController *)pageViewController {
    if (nil == _pageViewController) {
        
        NSDictionary *options = @{
            UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationMax)
        };
        UIPageViewController *pageViewController =
        [[UIPageViewController alloc]
         initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
         navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
         options:options];
        pageViewController.dataSource = self;
        pageViewController.delegate = self;
        [self addChildViewController:pageViewController];
        _pageViewController = pageViewController;
    }
    return _pageViewController;
}

- (NSMutableArray *)guideControllers {
	if (nil == _guideControllers) {
		_guideControllers = [NSMutableArray array];
	}
	return _guideControllers;
}

// MARK: - Initialization
- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        
        [self regiseterNotification];
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

- (void)dealloc {
	LZLog();
	LZQuickUnit.notificationRemove(self, LZStartPageDidCloseNotification);
}

// MARK: - Public
+ (BOOL (^)(void))needGuide {
    return  ^BOOL (void) {
        return [self parseTriggerInVersion];
    };
}

+ (void (^)(void))clearTrigger {
    return ^ {
        [self clearTriggerInVersion];
    };
}

+ (void (^)(void))updateTrigger {
    return ^ {
        [self updateTriggerInVersion];
    };
}

+ (LZGuideViewController * _Nonnull (^)(void))instance {
    return ^id {
        return [self viewControllerFromstoryboard:NSStringFromClass(self)
                                         inBundle:@"LZStartPageController"];
    };
}

- (LZGuideViewController * _Nonnull (^)(id<LZGuidePageDelegate> _Nonnull))delegate {
    return ^id (id<LZGuidePageDelegate> _Nonnull delegate) {
        self->_delegate = delegate;
        return self;
    };
}

- (LZGuideViewController * _Nonnull (^)(NSArray<UIViewController *> *))guideViewControllers {
    return ^id (NSArray<UIViewController *> *guideViewControllers) {
        NSAssert(nil != guideViewControllers && 0 != guideViewControllers.count, @"引导页不能为空");
        if (self.guideControllers.count) {
            [self.guideControllers removeAllObjects];
        }
        for (UIViewController *viewCtr in guideViewControllers) {
            if ([viewCtr isKindOfClass:[UIViewController class]]) {
                [self.guideControllers addObject:viewCtr];
            }
        }
        [self.pageViewController setViewControllers:@[self.guideControllers.firstObject]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:^(BOOL finished) {
        }];
        return self;
    };
}

- (LZGuideViewController * _Nonnull (^)(void))defaultConfig {
    return ^id {
        return self;
    };
}

- (LZGuideViewController * _Nonnull (^)(void))updateAppearance {
    return ^id {
        [self updateAllControlAppearence];
        return self;
    };
}

- (LZGuideViewController * _Nonnull (^)(BOOL))showSkipControl {
    return ^id (BOOL showSkipControl) {
        self->_showSkipControl = showSkipControl;
        return self;
    };
}

- (LZGuideViewController * _Nonnull (^)(NSString * _Nonnull))skipTitlel {
    return ^id (NSString * skipTitlel) {
        self->_skipTitle = skipTitlel;
        return self;
    };
}

- (LZGuideViewController * _Nonnull (^)(UIColor * _Nonnull))skipTitleColor {
    return ^id (UIColor * skipTitleColor) {
        self->_skipTitleColor = skipTitleColor;
        return self;
    };
}

- (LZGuideViewController * _Nonnull (^)(UIColor * _Nonnull))skipBGColor {
    return ^id (UIColor * skipBGColor) {
        self->_skipBGColor = skipBGColor;
        return self;
    };
}

- (LZGuideViewController * _Nonnull (^)(BOOL))showPageControl {
    return ^id (BOOL showPageControl) {
        self->_showPageControl = showPageControl;
        return self;
    };
}

- (LZGuideViewController * _Nonnull (^)(UIColor * _Nonnull))pageColor {
    return ^id (UIColor * pageColor) {
        self->_pageColor = pageColor;
        return self;
    };
}

- (LZGuideViewController * _Nonnull (^)(UIColor * _Nonnull))currentPageColor {
    return ^id (UIColor * currentPageColor) {
        self->_currentPageColor = currentPageColor;
        return self;
    };
}

- (LZGuideViewController * _Nonnull (^)(BOOL))showTheEntranceControl {
    return ^id (BOOL showTheEntranceControl) {
        self->_showTheEntranceControl = showTheEntranceControl;
        return self;
    };
}

- (LZGuideViewController * _Nonnull (^)(NSString * _Nonnull))theEntranceTitle {
    return ^id (NSString * theEntranceTitle) {
        self->_theEntranceTitle = theEntranceTitle;
        return self;
    };
}

- (LZGuideViewController * _Nonnull (^)(UIColor * _Nonnull))theEntranceTitleColor {
    return ^id (UIColor * theEntranceTitleColor) {
        self->_theEntranceTitleColor = theEntranceTitleColor;
        return self;
    };
}

- (LZGuideViewController * _Nonnull (^)(UIColor * _Nonnull))theEntranceBGColor {
    return ^id (UIColor * theEntranceBGColor) {
        self->_theEntranceBGColor = theEntranceBGColor;
        return self;
    };
}

- (LZGuideViewController * _Nonnull (^)(UIColor * _Nonnull))theEntranceBorderColor {
    return ^id (UIColor * theEntranceBorderColor) {
        self->_theEntranceBorderColor = theEntranceBorderColor;
        return self;
    };
}

- (LZGuideViewController * _Nonnull (^)(BOOL))infiniteScrolling {
    return ^id (BOOL infiniteScrolling) {
        self->_infiniteScrolling = infiniteScrolling;
        return self;
    };
}

// MARK: - UI Action
- (IBAction)skipDidTouchDown:(id)sender {
	[self closedByTrigger:LZStartPageCloseTriggerSkip];
}

- (IBAction)exprienceDidTouchDown:(id)sender {
    [self closedByTrigger:LZStartPageCloseTriggerEnter];
}

// MARK: - Private
- (void)setupDefaultValue {
    
    self.currentIndex = 0;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    id value = self
    .showSkipControl(YES)
    .skipTitlel(@"跳过")
    .skipTitleColor([UIColor blackColor])
    .skipBGColor([UIColor colorWithHexString:@"#DAEEFF"])
    .showPageControl(YES)
    .pageColor([UIColor colorWithHexString:@"#A9A6AA"])
    .currentPageColor([UIColor colorWithHexString:@"#299FF7"])
    .showTheEntranceControl(YES)
    .theEntranceTitle(@"立即体验")
    .theEntranceTitleColor([UIColor whiteColor])
    .theEntranceBGColor([UIColor colorWithHexString:@"#299FF7"])
    .theEntranceBorderColor([UIColor whiteColor])
    .infiniteScrolling(YES);
#pragma clang diagnostic pop
}

- (void)regiseterNotification {
    LZQuickUnit.notificationAdd(self, @selector(pageViewControllerDidCloseNotification:), LZStartPageDidCloseNotification);
}

- (void)setupUI {
    [self configSubControl];
}

- (void)configSubControl {
    
    [self.view addSubview:self.pageViewController.view];
    self.pageViewController.view.frame = self.view.bounds;
    
    self.skipBtn.layer.cornerRadius = self.skipBtn.height * 0.5f;
    self.skipBtn.layer.masksToBounds = YES;
    
    self.exprienceBtn.hidden = YES;
    self.exprienceBtn.layer.cornerRadius = 8.0f;
    self.exprienceBtn.layer.masksToBounds = YES;
    self.exprienceBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.exprienceBtn.layer.borderWidth = 2.0f;
    
    [self.view bringSubviewToFront:self.skipBtn];
    [self.view bringSubviewToFront:self.pageControl];
    [self.view bringSubviewToFront:self.exprienceBtn];
}

- (void)updateAllControlAppearence {
    
    self.skipBtn.hidden = !self->_showSkipControl;
    if (self->_showSkipControl) {
        
        [self.skipBtn setTitle:self->_skipTitle forState:UIControlStateNormal];
        [self.skipBtn setTitleColor:self->_skipTitleColor forState:UIControlStateNormal];
        [self.skipBtn setBackgroundColor:self->_skipBGColor];
    }
    self.pageControl.hidden = !self->_showPageControl;
    if (self->_showPageControl) {
        
        self.pageControl.pageIndicatorTintColor = self->_pageColor;
        self.pageControl.currentPageIndicatorTintColor = self->_currentPageColor;
    }
//    self.exprienceBtn.hidden = !self->_showTheEntranceControl;
    if (self->_showTheEntranceControl) {
        
        [self.exprienceBtn setTitle:self->_theEntranceTitle forState:UIControlStateNormal];
        [self.exprienceBtn setTitleColor:self->_theEntranceTitleColor forState:UIControlStateNormal];
        [self.exprienceBtn setBackgroundColor:self->_theEntranceBGColor];
        self.exprienceBtn.layer.borderColor = [self->_theEntranceBorderColor CGColor];
    }
}

- (void)closedByTrigger:(LZStartPageCloseTrigger)trigger {
	
	[[self class] updateTriggerInVersion];
	[self dismiss];
	SEL selector = @selector(guideViewController:currentIndex:didCloseTrigger:);
	if ([self->_delegate respondsToSelector:selector]) {
		[self->_delegate guideViewController:self
                                currentIndex:self.currentIndex
                             didCloseTrigger:trigger];
	}
}

+ (void)updateTriggerInVersion {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:LZAppUnit.version() forKey:LZGuidePageShowInVersionKey];
	[defaults synchronize];
}

+ (BOOL)parseTriggerInVersion {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastVersion = [defaults stringForKey:LZGuidePageShowInVersionKey];
    if (nil == lastVersion) {
        return YES;
    }
    BOOL isNewVersion = LZAppUnit.compareVersion(lastVersion);
    return NO == isNewVersion;
}

+ (void)clearTriggerInVersion {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:LZGuidePageShowInVersionKey];
    [defaults synchronize];
}

// MARK: - Observer
- (void)pageViewControllerDidCloseNotification:(NSNotification *)notification {
	
	NSNumber *number = notification.object;
	LZStartPageCloseTrigger trigger = number.unsignedIntValue;
	[self closedByTrigger:trigger];
}

// MARK: - Delegate
// MARK: <UIPageViewControllerDataSource>
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
	   viewControllerAfterViewController:(UIViewController *)viewController {
	LZLog(@"后一个视图控制器");
    NSInteger after = self.currentIndex + 1;
	if (after >= self.guideControllers.count) {
        if (self->_infiniteScrolling) {
            return self.guideControllers[0];
        } else {
            return nil;
        }
	}
	return self.guideControllers[after];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
	  viewControllerBeforeViewController:(UIViewController *)viewController {
	LZLog(@"前一个视图控制器");
    NSInteger before = self.currentIndex - 1;
	if (before < 0) {
        if (self->_infiniteScrolling) {
            return self.guideControllers[self.guideControllers.count - 1];
        } else {
            return nil;
        }
	}
	return self.guideControllers[before];
}

// MARK: <UIPageViewControllerDelegate>
- (void)pageViewController:(UIPageViewController *)pageViewController
willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
	self.currentViewController = pendingViewControllers.firstObject;
}

- (void)pageViewController:(UIPageViewController *)pageViewController
		didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
	   transitionCompleted:(BOOL)completed {
	if (YES == finished && YES == completed) {
		[self.guideControllers enumerateObjectsUsingBlock:^(UIViewController *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			if (obj == self.currentViewController) {
				// 判断视图控制器是否与正在转换的视图控制器为同一个
				self.currentIndex = idx;
				self.pageControl.currentPage = self.currentIndex;
                if ([obj isEqual:[self.guideControllers lastObject]]) {
                    
                    self.exprienceBtn.alpha = 0.0f;
                    self.exprienceBtn.hidden = !self->_showTheEntranceControl;
                    if (self->_showTheEntranceControl) {
                        [UIView animateWithDuration:0.25 animations:^{
                            self.exprienceBtn.alpha = 1.0f;
                        } completion:^(BOOL finished) {

                        }];
                    }
                } else {
                    self.exprienceBtn.hidden = YES;
                }
				*stop = YES;
            }
		}];
    } else {
        if (YES == completed) {
            self.exprienceBtn.hidden = YES;
        }
        self.pageControl.currentPage = self.currentIndex;
    }
}

- (UIInterfaceOrientationMask)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController {
	return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)pageViewControllerPreferredInterfaceOrientationForPresentation:(UIPageViewController *)pageViewController {
	return UIInterfaceOrientationPortrait;
}

@end
