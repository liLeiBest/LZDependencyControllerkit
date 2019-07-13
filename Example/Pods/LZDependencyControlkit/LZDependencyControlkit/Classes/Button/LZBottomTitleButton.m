//
//  LZBottomTitleButton.m
//  Pods
//
//  Created by Dear.Q on 16/8/13.
//
//

#import "LZBottomTitleButton.h"

@implementation LZBottomTitleButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.imageView.contentMode = UIViewContentModeBottom;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.imageView.contentMode = UIViewContentModeBottom;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return self;
}

/** 图像在按钮中的RECT */
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageW = self.frame.size.width;
    CGFloat imageH = self.frame.size.height * 0.7;
    
    return CGRectMake(imageX, imageY, imageW, imageH);
}

/** 标题在按钮中的RECT */
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = 0;
    CGFloat titleY = self.frame.size.height * 0.7;
    CGFloat titleW = self.frame.size.width;
    CGFloat titleH = self.frame.size.height * 0.3;
    
    return CGRectMake(titleX, titleY, titleW, titleH);
}

@end
