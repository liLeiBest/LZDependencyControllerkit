//
//  LZCopyLabel.m
//  LZDependencyControlkit
//
//  Created by Dear.Q on 2019/6/28.
//

#import "LZCopyLabel.h"

@implementation LZCopyLabel

// MARK: - Initializaiton
- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self longPressAGestureRecognizer];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self longPressAGestureRecognizer];
	}
	return self;
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	
	if (action == @selector(custCopy:)) {
		return YES;
	}
	return NO;
}

- (void)custCopy:(id)sender {
	
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	if (self.text) {
		pasteboard.string = self.text;
	}else{
		pasteboard.string = self.attributedText.string;
	}
}

// MARK: - UI Action
- (void)longPressAction:(UILongPressGestureRecognizer *)gesture {
	
	[self becomeFirstResponder];
	UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"拷贝" action:@selector(custCopy:)];
	[[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:copyItem, nil]];
	[[UIMenuController sharedMenuController] setTargetRect:self.frame inView:self.superview];
	[[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
}

// MARK: - Private
- (void)longPressAGestureRecognizer {
	
	self.userInteractionEnabled = YES;
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
	longPress.minimumPressDuration = 1;
	[self addGestureRecognizer:longPress];
}

@end
