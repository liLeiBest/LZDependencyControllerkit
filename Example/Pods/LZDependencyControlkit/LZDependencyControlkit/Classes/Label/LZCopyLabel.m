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
		[self setup];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self setup];
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
	} else {
		pasteboard.string = self.attributedText.string;
	}
}

// MARK: - UI Action
- (void)longPressAction:(UILongPressGestureRecognizer *)gesture {
	
	[self becomeFirstResponder];
	
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
	NSRange range = NSMakeRange(0, self.text.length);
	NSDictionary *textAttributes = @{NSBackgroundColorAttributeName : [UIColor colorWithRed:59.0 green:126.0 blue:251.0 alpha:255.0]};
	[attributedString addAttributes:textAttributes range:range];
	self.attributedText = attributedString;
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(showMenuController)
	 name:UIMenuControllerWillShowMenuNotification
	 object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(hideMenuController)
	 name:UIMenuControllerWillHideMenuNotification
	 object:nil];
	
	UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:self.menuTitle action:@selector(custCopy:)];
	[[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:copyItem, nil]];
	NSDictionary *copyAttributes = @{NSFontAttributeName : self.font};
	CGRect textFrame =
	[self.text boundingRectWithSize:self.frame.size
							options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
						 attributes:copyAttributes
							context:nil];
	[[UIMenuController sharedMenuController] setTargetRect:textFrame inView:self];
	[[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
}

// MARK: - Private
- (void)setup {
	
	self.selectedBgColor = [UIColor colorWithRed:59/255.0 green:126/255.0 blue:1 alpha:1];
	self.menuTitle = @"拷贝";
	
	self.userInteractionEnabled = YES;
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
	longPress.minimumPressDuration = 0.25f;
	[self addGestureRecognizer:longPress];
}

// MARK: - Observer
- (void)showMenuController {
	
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
	NSRange range = NSMakeRange(0, self.text.length);
	UIColor *bgColor = self.selectedBgColor;
	NSDictionary *textAttributes = @{NSBackgroundColorAttributeName : bgColor,
									 };
	[attributedString addAttributes:textAttributes range:range];
	self.attributedText = attributedString;
}

- (void)hideMenuController {
	
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
	NSDictionary *attributes = @{NSBackgroundColorAttributeName : [UIColor clearColor]};
	[attributedString addAttributes:attributes range:NSMakeRange(0, self.text.length)];
	self.attributedText = attributedString;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
