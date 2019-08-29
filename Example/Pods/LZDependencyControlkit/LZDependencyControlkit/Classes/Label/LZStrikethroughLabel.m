//
//  LZStrikethroughLabel.m
//  Pods
//
//  Created by Dear.Q on 2019/7/14.
//

#import "LZStrikethroughLabel.h"

@implementation LZStrikethroughLabel

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	[self.textColor set];
	CGFloat w = rect.size.width;
	CGFloat h = rect.size.height * 0.5;
	UIRectFill(CGRectMake(0, h, w, 1));
}

@end
