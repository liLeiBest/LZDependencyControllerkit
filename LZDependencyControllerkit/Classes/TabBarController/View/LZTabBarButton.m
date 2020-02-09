//
//  LZTabBarButton.m
//  Pods
//
//  Created by Dear.Q on 16/8/11.
//
//

#import "LZTabBarButton.h"
#import <LZDependencyControlkit/LZBadgeButton.h>

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
@property (nonatomic, weak) LZBadgeButton *badgeBtn;

@end
@implementation LZTabBarButton

// MARK: - Initialization
- (instancetype)init {
    
    if (self = [super init]) {
        
        // 设置默值
        _margin = 10.0f;
        _titleNormalColor = [UIColor grayColor];
        _titleSelectedColor = [UIColor blueColor];
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        [self setTitleColor:_titleNormalColor forState:UIControlStateNormal];
        [self setTitleColor:_titleSelectedColor forState:UIControlStateSelected];
        
        self.adjustsImageWhenHighlighted = NO;
        self.adjustsImageWhenDisabled = NO;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        // 添加小红点提示
        LZBadgeButton *badgeBtn = [[LZBadgeButton alloc] init];
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
    [self.item removeObserver:self forKeyPath:@"badgeValue"];
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

// MAKR: - Public
- (void)setItem:(UITabBarItem *)item {
    _item = item;
    
    self.imageProportion = 0.5f;
    if (nil == item.title || 0 == item.title.length) {
        if (item.image) {
            self.imageProportion = 1.0f;
        }
    } else {
        if (item.image) {
            self.imageProportion = 0.7f;
        } else {
            self.imageProportion = 0.0f;
        }
    }
    
    // 注册监听
    [_item addObserver:self
            forKeyPath:@"badgeValue"
               options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
               context:nil];
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
