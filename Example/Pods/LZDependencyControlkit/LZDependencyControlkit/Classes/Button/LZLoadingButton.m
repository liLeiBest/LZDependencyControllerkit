//
//  LZBadgeButton.m
//  Pods
//
//  Created by Dear.Q on 16/8/12.
//
//

#import "LZLoadingButton.h"

@interface LZLoadingButton()
{
    /** 遮盖层 */
    CAShapeLayer *maskLayer;
    /** 白色层 */
    CAShapeLayer *shapeLayer;
    /** 加载层 */
    CAShapeLayer *loadingLayer;
    /** 白圈层 */
    CAShapeLayer *circleLayer;
    /** 按钮 */
    UIButton *button;
    
    /** 标题 */
    NSString *btnTitle;
    /** 标题颜色 */
    UIColor *btnTitleColor;
    /** 按钮事件 Target */
    id btnActionTarget;
    /** 按钮点击事件 */
    SEL btnClickSelector;
}
@end
@implementation LZLoadingButton

#pragma mark - - View Init
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setupDefaultValue];
        [self setupSubViews];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    shapeLayer.strokeColor = self.shapeColor.CGColor;
    
    shapeLayer.path = [self drawBezierPath:self.frame.size.height * 0.5f].CGPath;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = self.shapeColor.CGColor;
    shapeLayer.lineWidth = 1.0f;
}

#pragma mark - - UI Event
- (void)clickBtn
{
    [self clickAnimation];
}

#pragma mark - - Public
- (instancetype)initWithTitle:(NSString *)title
                   titleColor:(UIColor *)titleColor
                  borderColor:(UIColor *)borderColor
                        frame:(CGRect)frame
{
    if (self = [super init])
    {
        btnTitle = title;
        btnTitleColor = titleColor;
        self.shapeColor = borderColor;
        self.circleColor = borderColor;
        self.maskColor = borderColor;
        self.loadColor = borderColor;
        self.frame = frame;
        
        [self setupSubViews];
    }
    
    return self;
}

- (void)addTarget:(id)target
           action:(SEL)action
{
    btnClickSelector = action;
    btnActionTarget = target;
    [button addTarget:self
               action:@selector(clickAnimation)
     forControlEvents:UIControlEventTouchUpInside];
}

- (void)animationFinish
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [self removeSubViews];
        [self setupSubViews];
		if ([self->btnActionTarget respondsToSelector:self->btnClickSelector])
			[self addTarget:self->btnActionTarget
					 action:self->btnClickSelector];
    });
}

#pragma mark - - Private
/**
 设置默认值
 */
- (void)setupDefaultValue
{
    btnTitle = @"Button";
    self.shapeColor = [UIColor whiteColor];
    self.circleColor = [UIColor whiteColor];
    self.maskColor = [UIColor whiteColor];
    self.loadColor = [UIColor whiteColor];
    self.minAnimationTime = 3.0f;
}

/**
 设置子控件
 */
- (void)setupSubViews
{
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    [self.layer addSublayer:shapeLayer];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = self.bounds;
    [button setTitle:btnTitle forState:UIControlStateNormal];
    [button setTitleColor:btnTitleColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13.f];
    [self addSubview:button];
}

/**
 按钮动画，小白圈
 */
- (void)clickAnimation
{
    circleLayer = [CAShapeLayer layer];
    circleLayer.position = CGPointMake(self.bounds.size.width * 0.5f,
                                            self.bounds.size.height * 0.5f);
    circleLayer.fillColor = self.circleColor.CGColor;
    circleLayer.path = [self drawCircleBezierPath:0].CGPath;
    [self.layer addSublayer:circleLayer];
    
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    basicAnimation.duration = 0.15f;
    basicAnimation.toValue = (__bridge id _Nullable)([self drawCircleBezierPath:(self.bounds.size.height - 10 * 2) * 0.5f].CGPath);
    basicAnimation.removedOnCompletion = NO;
    basicAnimation.fillMode = kCAFillModeForwards;
    [circleLayer addAnimation:basicAnimation forKey:@"clickCicrleAnimation"];
    
    [self performSelector:@selector(clickNextAnimation)
               withObject:self
               afterDelay:basicAnimation.duration];
}

/**
 按钮动画，小白圈消失
 */
- (void)clickNextAnimation
{
    circleLayer.fillColor = [UIColor clearColor].CGColor;
    circleLayer.strokeColor = self.circleColor.CGColor;
    circleLayer.lineWidth = 10.0f;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    basicAnimation.duration = 0.15f;
    basicAnimation.toValue = (__bridge id _Nullable)[self drawCircleBezierPath:self.bounds.size.height - 10 * 2].CGPath;
    basicAnimation.removedOnCompletion = NO;
    basicAnimation.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.beginTime = 0.10f;
    opacityAnimation.duration = 0.15f;
    opacityAnimation.toValue = @0.0f;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.fillMode = kCAFillModeForwards;
    
    animationGroup.duration = opacityAnimation.beginTime + opacityAnimation.duration;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.animations = @[basicAnimation, opacityAnimation];
    
    [circleLayer addAnimation:animationGroup forKey:@"clickCicrleAnimation"];
    
    [self performSelector:@selector(startMaskAnimation)
               withObject:self
               afterDelay:animationGroup.duration];
}

/**
 遮盖动画
 */
- (void)startMaskAnimation
{
    maskLayer = [CAShapeLayer layer];
    maskLayer.opacity = 0.15f;
    maskLayer.fillColor = self.maskColor.CGColor;
    maskLayer.path = [self drawBezierPath:self.frame.size.height * 0.5f].CGPath;
    [self.layer addSublayer:maskLayer];

    CABasicAnimation *basicAnimaton = [CABasicAnimation animationWithKeyPath:@"path"];
    basicAnimaton.duration = 0.25f;
    basicAnimaton.toValue = (__bridge id _Nullable)[self drawBezierPath:self.frame.size.height * 0.5f].CGPath;
    basicAnimaton.removedOnCompletion = NO;
    basicAnimaton.fillMode = kCAFillModeForwards;
    [maskLayer addAnimation:basicAnimaton forKey:@"maskAnimation"];
    
    [self performSelector:@selector(dismissAnimation)
               withObject:self
               afterDelay:basicAnimaton.duration + 0.2f];
}

/**
 移除按钮动画
 */
- (void)dismissAnimation
{
    [self removeSubViews];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    basicAnimation.duration = 0.15f;
    basicAnimation.toValue = (__bridge id _Nullable)([self drawBezierPath:self.frame.size.width * 0.5f].CGPath);
    basicAnimation.removedOnCompletion = NO;
    basicAnimation.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.beginTime = 0.10f;
    opacityAnimation.duration = 0.15;
    opacityAnimation.toValue = @0.0f;
    basicAnimation.removedOnCompletion = NO;
    basicAnimation.fillMode = kCAFillModeForwards;
    
    animationGroup.animations = @[basicAnimation, opacityAnimation];
    animationGroup.duration = opacityAnimation.beginTime + opacityAnimation.duration;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    [shapeLayer addAnimation:animationGroup forKey:@"dismisAnimation"];
    
    [self performSelector:@selector(loadingAnimation)
               withObject:self
               afterDelay:animationGroup.duration];
}

/**
 加载中动画
 */
- (void)loadingAnimation
{
    loadingLayer = [CAShapeLayer layer];
    loadingLayer.position = CGPointMake(self.bounds.size.width * 0.5f,
                                        self.bounds.size.height * 0.5f);
    loadingLayer.fillColor = [UIColor clearColor].CGColor;
    loadingLayer.strokeColor = self.loadColor.CGColor;
    loadingLayer.lineWidth = 2.0f;
    loadingLayer.path = [self drawLoadingBezierPath].CGPath;
    [self.layer addSublayer:loadingLayer];
    
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    basicAnimation.fromValue = @(0);
    basicAnimation.toValue = @(M_PI * 2.0f);
    basicAnimation.duration = 0.5f;
    basicAnimation.repeatCount = LONG_MAX;
    [loadingLayer addAnimation:basicAnimation forKey:@"loadingAnimation"];
    
    if (0.0f < self.minAnimationTime)
    {
        [self performSelector:@selector(removeAllAnimation)
                   withObject:self
                   afterDelay:self.minAnimationTime];
    }
    else
    {
        if ([btnActionTarget respondsToSelector:btnClickSelector])
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [btnActionTarget performSelector:btnClickSelector];
#pragma clang disagnostic pop
    }
}

- (void)removeAllAnimation
{
    [self removeSubViews];
   
    if ([btnActionTarget respondsToSelector:btnClickSelector])
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [btnActionTarget performSelector:btnClickSelector];
#pragma clang disagnostic pop
}

/**
 UIBezierPath
 */
- (UIBezierPath *)drawLoadingBezierPath
{
    CGFloat radius = self.bounds.size.height * 0.5f - 3.0f;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:CGPointMake(0, 0)
                          radius:radius
                      startAngle:M_PI_2
                        endAngle:M_PI
                       clockwise:YES];
    
    return bezierPath;
}

- (void)removeSubViews
{
    [button removeFromSuperview];
    [shapeLayer removeFromSuperlayer];
    [maskLayer removeFromSuperlayer];
    [loadingLayer removeFromSuperlayer];
    [circleLayer removeFromSuperlayer];
}

- (UIBezierPath *)drawCircleBezierPath:(CGFloat)radius
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:CGPointMake(0, 0)
                          radius:radius
                      startAngle:0
                        endAngle:M_PI * 2.0f
                       clockwise:YES];
    
    return bezierPath;
}

- (UIBezierPath *)drawBezierPath:(CGFloat)x
{
    CGFloat radius = self.bounds.size.height * 0.5f - 3.0f;
    CGFloat right = self.bounds.size.width - x;
    CGFloat left = x;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    bezierPath.lineCapStyle = kCGLineCapRound;
    [bezierPath addArcWithCenter:CGPointMake(right, self.bounds.size.height * 0.5f)
                          radius:radius
                      startAngle:-M_PI_2
                        endAngle:M_PI_2
                       clockwise:YES];
    [bezierPath addArcWithCenter:CGPointMake(left, self.bounds.size.height * 0.5f)
                          radius:radius
                      startAngle:M_PI_2
                        endAngle:-M_PI_2
                       clockwise:YES];
    [bezierPath closePath];
    
    return bezierPath;
}

@end
