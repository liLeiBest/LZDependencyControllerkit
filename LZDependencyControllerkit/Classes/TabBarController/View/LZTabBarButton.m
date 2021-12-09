//
//  LZTabBarButton.m
//  Pods
//
//  Created by Dear.Q on 16/8/11.
//
//

#import "LZTabBarButton.h"
#import "LZTabBarBadgeButton.h"

static NSString *kBadgeNumber = @"badgeValue";

@interface LZTabBarButton()

/** 字体未选中颜色 */
@property (nonatomic, strong) UIColor *titleNormalColor;
/** 字体高亮颜色 */
@property (nonatomic, strong) UIColor *titleSelectedColor;
/** 按钮与小红点距离 */
@property (nonatomic, assign) CGFloat margin;
/** 图片占比 */
@property (nonatomic, assign) CGFloat imageProportion;

/** 引用小红点  */
@property (nonatomic, weak) LZTabBarBadgeButton *badgeBtn;

@property (nonatomic, assign) BOOL beObserved;

@end
@implementation LZTabBarButton

// MARK: - Initialization
- (instancetype)init {
    if (self = [super init]) {
        // 设置默值
        _margin = 10.0f;
        _titleNormalColor = [UIColor grayColor];
        _titleSelectedColor = [UIColor blueColor];
        _imageProportion = 1.0f;
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        [self setTitleColor:_titleNormalColor forState:UIControlStateNormal];
        [self setTitleColor:_titleSelectedColor forState:UIControlStateSelected];
        
        self.adjustsImageWhenHighlighted = NO;
        self.adjustsImageWhenDisabled = NO;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.contentMode = UIViewContentModeScaleAspectFit;
        // 添加小红点提示
        LZTabBarBadgeButton *badgeBtn = [[LZTabBarBadgeButton alloc] init];
        self.badgeBtn = badgeBtn;
        [self addSubview:badgeBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.badgeBtn.x = self.width - self.badgeBtn.width - _margin;
    self.badgeBtn.y = 5.0f;
}

- (void)dealloc {
    [self removeBadgeObserver];
}

- (void)setHighlighted:(BOOL)highlighted {}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageW = self.frame.size.width;
    CGFloat imageH = self.frame.size.height * self.imageProportion;
    return CGRectMake(imageX, imageY, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {

    CGFloat titleX = 0;
    CGFloat titleY = self.frame.size.height * self.imageProportion;
    CGFloat titleW = self.frame.size.width;
    CGFloat titleH = self.frame.size.height * (1 - self.imageProportion);
    return CGRectMake(titleX, titleY, titleW, titleH);
}

// MARK: - Setter
- (void)setItem:(UITabBarItem *)item {
    _item = item;
    
    [self updateProportionOfTitleAndImage];
    if (NO == self.beObserved) {
        
        self.beObserved = YES;
        [self.item addObserver:self
                    forKeyPath:kBadgeNumber
                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                       context:nil];
    }
}

// MARK: - Private
- (void)updateProportionOfTitleAndImage {
    
    self.imageProportion = 0.5f;
    if (NO == [self hasTitle]) {
        if (YES == [self hasImage]) {
            self.imageProportion = 1.0f;
        } else {
            if (YES == [self hasBgImage]) {
                self.imageProportion = 1.0f;
            }
        }
    } else {
        if (YES == [self hasImage]) {
            
            self.imageProportion = 0.7f;
            self.imageView.contentMode = UIViewContentModeBottom;
        } else {
            self.imageProportion = 0.0f;
        }
    }
}

- (BOOL)hasTitle {
    return (nil != self.currentTitle && 0 < self.currentTitle.length)
    || nil != self.currentAttributedTitle;
}

- (BOOL)hasImage {
    return nil != self.currentImage;
}

- (BOOL)hasBgImage {
    return nil != self.currentBackgroundImage;
}

- (void)removeBadgeObserver {
    @try {
        [self.item removeObserver:self forKeyPath:kBadgeNumber];
    } @catch (NSException *exception) {
    } @finally {
    }
}

// MARK: - Observer
/**
 *  监听item的属性badgeValue值的变化
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    self.badgeBtn.badgeValue = change[@"new"];
}

@end
