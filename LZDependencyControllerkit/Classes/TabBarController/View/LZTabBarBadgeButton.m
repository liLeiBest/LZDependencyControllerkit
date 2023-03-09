//
//  LZTabBarBadgeButton.m
//  LZDependencyControlkit
//
//  Created by Dear.Q on 2020/2/13.
//

#import "LZTabBarBadgeButton.h"
#import <LZDependencyToolkit/LZDependencyToolkit.h>

@interface LZTabBarBadgeButton()

/** 默认小红点的大小 */
@property (nonatomic, assign) CGFloat dotSize;
/** 默认的字体大小 */
@property (nonatomic, assign) CGFloat fontSize;
/** 默认小红点颜色 */
@property (nonatomic, strong) UIColor *backgroundColor;

@end
@implementation LZTabBarBadgeButton

// MARK: - Initialziation
- (instancetype)init {
    
    if (self = [super init]) {
        
        self.userInteractionEnabled = NO;
        
        // 设置默认值
        self.hidden = YES;
        _badgeValue = @"0";
        _dotSize = 8;
        self.size = CGSizeMake(_dotSize, _dotSize);
        _fontSize = 9;
        self.titleLabel.font = [UIFont systemFontOfSize:_fontSize];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _backgroundColor = [UIColor redColor];
        self.backgroundColor = [UIColor redColor];
        UIImage *backImage = [UIImage imageWithColor:_backgroundColor
                                                size:CGSizeMake(_dotSize, _dotSize)];
        [self setBackgroundImage:backImage forState:UIControlStateNormal];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.layer.cornerRadius = self.height * 0.5;
    self.layer.masksToBounds = YES;
}

- (void)setHighlighted:(BOOL)highlighted {}

// MARK: - Public
- (void)setBadgeValue:(NSString *)badgeValue {
    _badgeValue = badgeValue;
    
    self.hidden = NO;
    // 不显示数字
    if (0 > badgeValue.integerValue) {
        
        self.size = CGSizeMake(_dotSize, _dotSize);
        self.layer.cornerRadius = _dotSize * 0.5;
        return;
    }
    // 等于“0”，隐藏小红点
    if (0 == _badgeValue.intValue) {
        self.hidden = YES;
        return;
    }
    // 显示数字
    switch (_badgeValue.length) {
        case 1: {
            
            [self setTitle:badgeValue forState:UIControlStateNormal];
            self.width = _dotSize + 7;
        }
            break;
        case 2: {
            
            [self setTitle:badgeValue forState:UIControlStateNormal];
            self.width = _dotSize + 10;
        }
            break;
        case 3: {
            
            [self setTitle:@"99+" forState:UIControlStateNormal];
            self.width = _dotSize + 13;
        }
            break;
        default:
            break;
    }
    self.height = _dotSize + 7;
}

@end
