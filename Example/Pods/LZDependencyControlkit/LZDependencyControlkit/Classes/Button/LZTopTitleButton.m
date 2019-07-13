//
//  LZTopTitleButton.m
//  Pods
//
//  Created by Dear.Q on 16/8/13.
//
//

#import "LZTopTitleButton.h"

@implementation LZTopTitleButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        self.imageView.contentMode = UIViewContentModeTop;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.imageView.contentMode = UIViewContentModeTop;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return self;
}

/** 标题在按钮中的RECT */
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = 0;
    CGFloat titleY = 0;
    CGFloat titleW = self.frame.size.width;
    CGFloat titleH = self.frame.size.height * 0.4;
    
    return CGRectMake(titleX, titleY, titleW, titleH);
}

/** 图像在按钮中的RECT */
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageX = 0;
    CGFloat imageY = self.frame.size.height * 0.4;
    CGFloat imageW = self.frame.size.width;
    CGFloat imageH = self.frame.size.height * 0.6;
    
    return CGRectMake(imageX, imageY, imageW, imageH);
}

@end
