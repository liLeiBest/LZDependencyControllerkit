//
//  LZFixedButton.m
//  LZDependencyControlkit
//
//  Created by Dear.Q on 2020/2/12.
//

#import "LZFixedButton.h"

@implementation LZFixedButton

// MARK: - Initialization
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self configContentMode];
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageW = 0;
    CGFloat imageH = 0;
    switch (self.titlePosition) {
        case LZFixedButtonTitlePositionTop:
            
            imageY = self.frame.size.height * self.titleProportionInButton;
            imageW = self.frame.size.width;
            imageH = self.frame.size.height * (1 - self.titleProportionInButton);
            break;
         case LZFixedButtonTitlePositionLeft:
            
            imageX = self.frame.size.width * self.titleProportionInButton;
            imageW = self.frame.size.width - imageX;
            imageH = self.frame.size.height;
            break;
        case LZFixedButtonTitlePositionBottom:
        
            imageW = self.frame.size.width;
            imageH = self.frame.size.height * (1 - self.titleProportionInButton);
            break;
        default:
            break;
    }
    return CGRectMake(imageX, imageY, imageW, imageH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    
    CGFloat titleX = 0;
    CGFloat titleY = 0;
    CGFloat titleW = 0;
    CGFloat titleH = 0;
    switch (self.titlePosition) {
        case LZFixedButtonTitlePositionTop:
            
            titleW = self.frame.size.width;
            titleH = self.frame.size.height * self.titleProportionInButton;
            break;
         case LZFixedButtonTitlePositionLeft:
            
            titleW = self.frame.size.width * self.titleProportionInButton;
            titleH = self.frame.size.height;
            break;
        case LZFixedButtonTitlePositionBottom:
        
            titleY = self.frame.size.height * (1 - self.titleProportionInButton);
            titleW = self.frame.size.width;
            titleH = self.frame.size.height * self.titleProportionInButton;
        break;
        default:
            break;
    }
    return CGRectMake(titleX, titleY, titleW, titleH);
}

// MARK: - Private
- (void)configContentMode {
    
    switch (self.titlePosition) {
        case LZFixedButtonTitlePositionTop:
            
            self.imageView.contentMode = UIViewContentModeTop;
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            break;
         case LZFixedButtonTitlePositionLeft:
            
            self.imageView.contentMode = UIViewContentModeLeft;
            self.titleLabel.textAlignment = NSTextAlignmentRight;
            break;
        case LZFixedButtonTitlePositionBottom:
        
            self.imageView.contentMode = UIViewContentModeBottom;
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
        break;
        default:
            break;
    }
}
@end
