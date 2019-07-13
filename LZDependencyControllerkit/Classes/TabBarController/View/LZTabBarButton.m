//
//  LZTabBarButton.m
//  Pods
//
//  Created by Dear.Q on 16/8/11.
//
//

#import "LZTabBarButton.h"
#import <LZDependencyControlkit/LZBadgeButton.h>
#import <LZDependencyToolkit/UIView+LZExtension.h>

@interface LZTabBarButton()

/** 字体未选中颜色 */
@property (nonatomic, strong) UIColor *titleNormalColor;
/** 字体高亮颜色 */
@property (nonatomic, strong) UIColor *titleSelectedColor;
/** 按钮与小红点距离 */
@property (nonatomic, assign) CGFloat margin;

/** 引用小红点  */
@property (nonatomic, weak) LZBadgeButton *badgeBtn;

@end
@implementation LZTabBarButton

- (instancetype)init
{
    if (self = [super init])
    {
        // 设置默值
        _margin = 10.0f;
        _titleNormalColor = [UIColor grayColor];
        _titleSelectedColor = [UIColor blueColor];
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        [self setTitleColor:_titleNormalColor forState:UIControlStateNormal];
        [self setTitleColor:_titleSelectedColor forState:UIControlStateSelected];
        
        // 添加小红点提示
        LZBadgeButton *badgeBtn = [[LZBadgeButton alloc] init];
        self.badgeBtn = badgeBtn;
        [self addSubview:badgeBtn];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.badgeBtn.x = self.width - self.badgeBtn.width - _margin;
    self.badgeBtn.y = 5.0f;
}

- (void)dealloc
{
    [self.item removeObserver:self forKeyPath:@"badgeValue"];
}

- (void)setItem:(UITabBarItem *)item
{
    _item = item;
    
    [self setTitle:item.title forState:UIControlStateNormal];
    [self setImage:item.image forState:UIControlStateNormal];
    [self setImage:item.selectedImage forState:UIControlStateSelected];
    
    // 注册监听
    [_item addObserver:self
            forKeyPath:@"badgeValue"
               options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
               context:nil];
}

/**
 *  监听item的属性badgeValue值的变化
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    self.badgeBtn.badgeValue = change[@"new"];
}

@end
