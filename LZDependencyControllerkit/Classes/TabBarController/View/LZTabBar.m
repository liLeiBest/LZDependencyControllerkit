//
//  LZTabBar.m
//  Pods
//
//  Created by Dear.Q on 16/8/11.
//  Copyright © 2016年 Dear.Q. All rights reserved.
//

#import "LZTabBar.h"
#import "LZTabBarButton.h"

@interface LZTabBar()

/** 保存规则菜单按钮 */
@property (nonatomic, strong) NSMutableArray *normalBtnArrM;
/** Plus按钮 */
@property (nonatomic, weak) LZTabBarButton *plusBtn;
/** TabBar按钮 */
@property (nonatomic, strong) LZTabBarButton *currentSelectedButton;

@end

@implementation LZTabBar

// MARK: - Lazy Loading
- (NSMutableArray *)normalBtnArrM {
    if (nil == _normalBtnArrM) _normalBtnArrM = [NSMutableArray array];
    return _normalBtnArrM;
}

// MARK: - Initialization
- (instancetype)init {
    if (self = [super init]) {
        
        self.defaultSelectedIndex = 0;
        self.plusBtnOffsetY = 0;
    }
    return self;
}
- (instancetype)initWithPlusBtn {
    if (self == [super init]) {
        [self setupPlusbtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setupPlusTabBarButtonFrame];
    [self setupNormalTabBarButtonFrame];
}

// MARK: - UI Action
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.clipsToBounds && !self.hidden && self.alpha > 0) {

        CGPoint newPoint = [self convertPoint:point toView:self.plusBtn];
        if ([self.plusBtn pointInside:newPoint withEvent:event]) {
            return self.plusBtn;
        } else {
            return [super hitTest:point withEvent:event];
        }
    } else {
        return [super hitTest:point withEvent:event];
    }
}

- (void)plusBtnDidClick {
    if (self.tabBarPulsBtnDidClickBlock) {
        self.tabBarPulsBtnDidClickBlock(self);
    }
}

- (void)tabBarButtonClick:(LZTabBarButton *)tabBarButton {
    if (self.tabBarBtnDidClickBlock) {
        
        NSUInteger fromIndex = self.currentSelectedButton.tag;
        NSUInteger toIndex = tabBarButton.tag;
        self.currentSelectedButton.selected = NO;
        tabBarButton.selected = YES;
        self.currentSelectedButton = tabBarButton;
        self.tabBarBtnDidClickBlock(self, fromIndex, toIndex);
    }
}

// MARK: - Public
/** 设置加号按钮背景图 */
- (void)setupPlusBtnBackgroundImage:(UIImage *)backgroundImage
                           forState:(UIControlState)state {
    
    CGFloat top = (backgroundImage.size.height - self.plusBtnOffsetY) * 0.5;
    CGFloat left = backgroundImage.size.width * 0.5;
    CGFloat bottom = top;
    CGFloat right = left;
    backgroundImage  = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
    [self.plusBtn setBackgroundImage:backgroundImage forState:state];
}

/** 设置加号按钮的图标 */
- (void)setupPlusBtnImage:(UIImage *)image
                 forState:(UIControlState)state {
    [self.plusBtn setImage:image forState:state];
}

/** 设置加号按钮标题 */
- (void)setupPlusBtnTitle:(NSString *)title
                 forState:(UIControlState)state {
    
    [self.plusBtn setTitle:title forState:state];
    [self.plusBtn updateProportionOfTitleAndImage];
}

/** 设置加号按钮标题 */
- (void)setupPlusBtnAttributedTitle:(NSAttributedString *)title
                           forState:(UIControlState)state {
    
    [self.plusBtn setAttributedTitle:title forState:state];
    [self.plusBtn updateProportionOfTitleAndImage];
}

/** 添加TabBarButton */
- (void)addTabBarBtn:(UITabBarItem *)tabBarItem {
    // 实例TabBarBtn
    LZTabBarButton *tabBarBtn = [[LZTabBarButton alloc] init];
    tabBarBtn.tabBarBtnType = LZTabBarButtonTypeNormal;
    tabBarBtn.tag = nil == self.plusBtn ? self.subviews.count : self.subviews.count - 1;
    [tabBarBtn addTarget:self action:@selector(tabBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self setupNormalTabBarButtonAppearance:tabBarBtn tabBarItem:tabBarItem];
    [self addSubview:tabBarBtn];
    [self.normalBtnArrM addObject:tabBarBtn];
    // 默认选中第一个按钮
    if ((nil == self.plusBtn && self.defaultSelectedIndex + 1 == self.subviews.count) ||
        (nil != self.plusBtn && (self.defaultSelectedIndex + 2) == self.subviews.count)) {
        [self tabBarButtonClick:tabBarBtn];
    }
}

- (void)updateTabBarBtn:(UITabBarItem *)tabBarItem
                  index:(NSInteger)index {
    if (self.normalBtnArrM.count > index) {
            
        LZTabBarButton *tabBarBtn = [self.normalBtnArrM objectAtIndex:index];
        [self setupNormalTabBarButtonAppearance:tabBarBtn tabBarItem:tabBarItem];
    }
}

/** 更新选中项 */
- (void)updateSelectedIndex:(NSInteger)selectedIndex {
    if (self.normalBtnArrM.count > selectedIndex) {
        
        LZTabBarButton *btn = [self.normalBtnArrM objectAtIndex:selectedIndex];
        if (btn && [btn respondsToSelector:@selector(setSelected:)]) {
            
            self.currentSelectedButton.selected = NO;
            btn.selected = YES;
            self.currentSelectedButton = btn;
        }
    }
}

// MARK: - Private
/**
 @author Lilei
 
 @brief 设置加号按钮
 */
- (void)setupPlusbtn {
    
    LZTabBarButton *plusBtn = [[LZTabBarButton alloc] init];
    plusBtn.tabBarBtnType = LZTabBarButtonTypePlus;
    self.plusBtn = plusBtn;
    [plusBtn addTarget:self action:@selector(plusBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:plusBtn];
}

/**
 @author Lilei
 
 @brief 设置加号按钮的Frame
 */
- (void)setupPlusTabBarButtonFrame {
    
    NSUInteger count = self.subviews.count;
    CGFloat btnW = self.width / count;
//    UIImage *image = self.plusBtn.currentBackgroundImage ?: self.plusBtn.currentImage;
//    CGSize imageSize = image.size;
    self.plusBtn.width = btnW;
    self.plusBtn.height = self.height + self.plusBtnOffsetY; // imageSize.height;
    self.plusBtn.centerX = self.width * 0.5;
    self.plusBtn.centerY = self.height * 0.5;
}

/**
 @author Lilei
 
 @brief 根据自定义tabBarButton的个数，设置按钮的Frame
 */
- (void)setupNormalTabBarButtonFrame {
    
    NSUInteger count = self.subviews.count;
    CGFloat btnW = self.width / count;
    CGFloat btnH = self.height;
    __block CGFloat btnY = 0;
    [self.subviews enumerateObjectsUsingBlock:^(LZTabBarButton *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[LZTabBarButton class]]
            && obj.tabBarBtnType == LZTabBarButtonTypeNormal) {
            
            CGFloat btnX = nil == self.plusBtn ? idx * btnW : (idx - 1) * btnW;
            if (idx >= count * 0.5) btnX = idx * btnW;
            obj.frame = CGRectMake(btnX, btnY, btnW, btnH);
        }
    }];
}

- (void)setupNormalTabBarButtonAppearance:(LZTabBarButton *)tabBarBtn
                               tabBarItem:(UITabBarItem *)tabBarItem {
    
    NSDictionary *normalAttrs = [[UITabBarItem appearance] titleTextAttributesForState:UIControlStateNormal];
    NSDictionary *selectedAttrs = [[UITabBarItem appearance] titleTextAttributesForState:UIControlStateSelected];
    if (normalAttrs && selectedAttrs && tabBarItem.title) {
        
        NSAttributedString *normalAttrString =
        [[NSAttributedString alloc] initWithString:tabBarItem.title attributes:normalAttrs];
        [tabBarBtn setAttributedTitle:normalAttrString forState:UIControlStateNormal];
        NSAttributedString *selectedAttrString =
        [[NSAttributedString alloc] initWithString:tabBarItem.title attributes:selectedAttrs];
        [tabBarBtn setAttributedTitle:selectedAttrString forState:UIControlStateSelected];
    } else {
        
        [tabBarBtn setTitleColor:self.tabBarBtnNormalColor ? self.tabBarBtnNormalColor : [tabBarBtn titleColorForState:UIControlStateNormal]
                        forState:UIControlStateNormal];
        [tabBarBtn setTitleColor:self.tabBarBtnSelectedColor ? self.tabBarBtnSelectedColor : [tabBarBtn titleColorForState:UIControlStateSelected]
                        forState:UIControlStateSelected];
        tabBarBtn.titleLabel.font = self.tabBarBtnFont ? self.tabBarBtnFont : tabBarBtn.titleLabel.font;
        
        [tabBarBtn setTitle:tabBarItem.title forState:UIControlStateNormal];
    }
    [tabBarBtn setImage:tabBarItem.image forState:UIControlStateNormal];
    [tabBarBtn setImage:tabBarItem.selectedImage forState:UIControlStateSelected];
    tabBarBtn.item = tabBarItem;
}

@end
