//
//  LZRoundCornerImageView.m
//  LZDependent_control
//
//  Created by Dear.Q on 2019/5/21.
//

#import "LZRoundCornerImageView.h"

@implementation LZRoundCornerImageView

- (id)initWithCoder:(NSCoder *)aDecoder {
	
	if (self = [super initWithCoder:aDecoder]) {
		
		self.layer.cornerRadius = self.frame.size.width > self.frame.size.height ? self.frame.size.height * 0.5 : self.frame.size.width * 0.5;
		self.clipsToBounds = YES;
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		
		self.layer.cornerRadius = self.frame.size.width > self.frame.size.height ? self.frame.size.height * 0.5 : self.frame.size.width * 0.5;
		self.clipsToBounds = YES;
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat w = self.frame.size.width;
	CGFloat h = self.frame.size.height;
	CGFloat fitSize = w > h ? h : w;
	if (w > h) {
		
		CGRect frame = self.frame;
		frame.size.width = frame.size.height = fitSize;
		self.frame = frame;
	}
	
	self.layer.cornerRadius = fitSize * 0.5;
	self.clipsToBounds = YES;
}

@end
