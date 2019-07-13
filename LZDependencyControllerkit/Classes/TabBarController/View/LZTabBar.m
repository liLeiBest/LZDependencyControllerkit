//
//  LZTabBar.m
//  Pods
//
//  Created by Dear.Q on 16/8/11.
//  Copyright © 2016年 Dear.Q. All rights reserved.
//

#import "LZTabBar.h"
#import "LZTabBarButton.h"

#define LZMargin 10

@interface LZTabBar()

/** 保存规则菜单按钮 */
@property (nonatomic, strong) NSMutableArray *normalBtnArrM;
/** Plus按钮 */
@property (nonatomic, weak) LZBottomTitleButton1 *plusBtn;
/** TabBar按钮 */
@property (nonatomic, strong) LZTabBarButton *currentSelectedButton;

@end

@implementation LZTabBar

#pragma mark - 懒加载
- (NSMutableArray *)normalBtnArrM
{
    if (nil == _normalBtnArrM) _normalBtnArrM = [NSMutableArray array];
    
    return _normalBtnArrM;
}

#pragma mark - 视图初始化
- (instancetype)initWithPlusBtn
{
    if (self == [super init])
    {
        [self setupPlusbtn];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setupPlusTabBarButtonFrame];
    [self setupNormalTabBarButtonFrame];
}

#pragma mark - UI事件
/** 设置加号按钮的点事件处理 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!self.isHidden)
    {
        CGPoint newPoint = [self convertPoint:point toView:self.plusBtn];
        if ([self.plusBtn pointInside:newPoint withEvent:event])
        {
            return self.plusBtn;
        }
        else
        {
            return [super hitTest:point withEvent:event];
        }
    }
    else
    {
        return [super hitTest:point withEvent:event];
    }
}

/** 加号按钮点击事件 */
- (void)plusBtnDidClick
{
    if (self.tabBarPulsBtnDidClickBlock)
    {
        self.tabBarPulsBtnDidClickBlock(self);
    }
}

/** 普通按钮点击事件 */
- (void)tabBarButtonClick:(LZTabBarButton *)tabBarButton
{
    if (self.tabBarBtnDidClickBlock)
    {
        self.tabBarBtnDidClickBlock(self,
                                    self.currentSelectedButton.tag,
                                    tabBarButton.tag);
        
        self.currentSelectedButton.selected = NO;
        tabBarButton.selected = YES;
        self.currentSelectedButton = tabBarButton;
    }
}

#pragma mark - Public
/** 设置加号按钮背景图 */
- (void)setupPlusBtnBackgroundImage:(UIImage *)backgroundImage
                           forState:(UIControlState)state
{
    [self.plusBtn setBackgroundImage:backgroundImage forState:state];
}

/** 设置加号按钮的图标 */
- (void)setupPlusBtnImage:(UIImage *)image
                 forState:(UIControlState)state
{
    [self.plusBtn setImage:image forState:state];
}

/** 设置加号按钮标题 */
- (void)setupPlusBtnTitle:(NSString *)title
                 forState:(UIControlState)state
{
    [self.plusBtn setTitle:title forState:state];
}

/** 设置加号按钮标题 */
- (void)setupPlusBtnAttributedTitle:(NSAttributedString *)title
                           forState:(UIControlState)state
{
    [self.plusBtn setAttributedTitle:title forState:state];
}

/** 添加TabBarButton */
- (void)addTabBarBtn:(UITabBarItem *)tabBarItem
{
    // 实例TabBarBtn
    LZTabBarButton *tabBarBtn = [[LZTabBarButton alloc] init];
    [self.normalBtnArrM addObject:tabBarBtn];
    [tabBarBtn setTitleColor:self.tabBarBtnNormalColor ? self.tabBarBtnNormalColor : [tabBarBtn titleColorForState:UIControlStateNormal]
                    forState:UIControlStateNormal];
    [tabBarBtn setTitleColor:self.tabBarBtnSelectedColor ? self.tabBarBtnSelectedColor : [tabBarBtn titleColorForState:UIControlStateSelected]
                    forState:UIControlStateSelected];
    tabBarBtn.titleLabel.font = self.tabBarBtnFont ? self.tabBarBtnFont : tabBarBtn.titleLabel.font ;
    tabBarBtn.item = tabBarItem;
    tabBarBtn.tag = self.subviews.count;
    [tabBarBtn addTarget:self
                  action:@selector(tabBarButtonClick:)
        forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:tabBarBtn];
    
    // 默认选中第一个按钮
    if ((nil == self.plusBtn && 1 == self.subviews.count) ||
        (nil != self.plusBtn && 2 == self.subviews.count))
    {
        [self tabBarButtonClick:tabBarBtn];
    }
}

/** 更新选中项 */
- (void)updateSelectedIndex:(NSInteger)selectedIndex
{
    if (self.normalBtnArrM.count > selectedIndex)
    {
        LZTabBarButton *btn = [self.normalBtnArrM objectAtIndex:selectedIndex];
        if (btn && [btn respondsToSelector:@selector(setSelected:)])
        {
            self.currentSelectedButton.selected = NO;
            btn.selected = YES;
            self.currentSelectedButton = btn;
        }
    }
}

#pragma mark - Private
/**
 @author Lilei
 
 @brief 设置加号按钮
 */
- (void)setupPlusbtn
{
    LZBottomTitleButton1 *plusBtn = [[LZBottomTitleButton1 alloc] init];
    self.plusBtn = plusBtn;
    [plusBtn addTarget:self
                action:@selector(plusBtnDidClick)
      forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:plusBtn];
}

/**
 @author Lilei
 
 @brief 设置加号按钮的Frame
 */
- (void)setupPlusTabBarButtonFrame
{
    CGSize imageSize = self.plusBtn.currentBackgroundImage.size;
    self.plusBtn.width = imageSize.width;
    self.plusBtn.height = imageSize.height;
    self.plusBtn.centerX = self.width * 0.5 ;
    self.plusBtn.centerY = self.height * 0.5 - 8.5;
}

/**
 @author Lilei
 
 @brief 根据自定义tabBarButton的个数，设置按钮的Frame
 */
- (void)setupNormalTabBarButtonFrame
{
    NSUInteger count = self.subviews.count;
    CGFloat btnW = self.width / count;
    CGFloat btnH = self.height;
    
    __block CGFloat btnY = 0;
    [self.subviews enumerateObjectsUsingBlock:^(UIButton *obj,
                                                NSUInteger idx,
                                                BOOL *stop)
     {
         if ([obj isKindOfClass:[LZTabBarButton class]])
         {
             CGFloat btnX = nil == self.plusBtn ? idx * btnW : (idx - 1) * btnW;
             if (idx >= count * 0.5) btnX = idx * btnW;
             obj.frame = CGRectMake(btnX, btnY, btnW, btnH);
         }
     }];
}

@end