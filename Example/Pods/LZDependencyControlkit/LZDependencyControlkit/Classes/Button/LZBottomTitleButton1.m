//
//  LZBottomTitleButton1.m
//  Pods
//
//  Created by Dear.Q on 16/9/12.
//
//

#import "LZBottomTitleButton1.h"

@implementation LZBottomTitleButton1

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return self;
}

/** 图像在按钮中的RECT */
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageW = self.frame.size.width;
    CGFloat imageH = self.frame.size.height * 0.9;
    
    return CGRectMake(imageX, imageY, imageW, imageH);
}

/** 标题在按钮中的RECT */
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX = 0;
    CGFloat titleY = self.frame.size.height * 0.9;
    CGFloat titleW = self.frame.size.width;
    CGFloat titleH = self.frame.size.height * 0.1;
    
    return CGRectMake(titleX, titleY, titleW, titleH);
}

@end
