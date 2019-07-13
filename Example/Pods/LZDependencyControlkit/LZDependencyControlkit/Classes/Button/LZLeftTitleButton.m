//
//  LZLeftTitleButton.m
//  Pods
//
//  Created by Dear.Q on 16/8/13.
//
//

#import "LZLeftTitleButton.h"

@implementation LZLeftTitleButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.imageView.contentMode = UIViewContentModeLeft;
        self.titleLabel.textAlignment = NSTextAlignmentRight;
    }
    return self;
}

- (nonnull instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.imageView.contentMode = UIViewContentModeLeft;
        self.titleLabel.textAlignment = NSTextAlignmentRight;
    }
    
    return self;
}

/** 标题在按钮中的RECT */
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = 0;
    CGFloat titleY = 0;
    CGFloat titleW = self.frame.size.width * 0.5;
    CGFloat titleH = self.frame.size.height;
    
    return CGRectMake(titleX, titleY, titleW, titleH);
}

/** 图像在按钮中的RECT */
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageH = self.frame.size.height;
    CGFloat imageW = imageH;
    CGFloat imageX = self.frame.size.width * 0.5;
    CGFloat imageY = 0;
    
    return CGRectMake(imageX, imageY, imageW, imageH);
}

@end
