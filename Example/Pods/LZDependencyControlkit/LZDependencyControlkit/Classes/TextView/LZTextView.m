//
//  LZTextView.m
//  LZDependencyControlkit
//
//  Created by Dear.Q on 2019/6/28.
//

#import "LZTextView.h"

@implementation LZTextView

// MARK: - Initialization
- (id)initWithCoder:(NSCoder *)aDecoder {
	
	if (self = [super initWithCoder:aDecoder]) {
		
		// 创建提示文本
		UILabel *placeHolder = [[UILabel alloc] init];
		placeHolder.numberOfLines = 0;
		[self addSubview:placeHolder];
		// 添加监听
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(textDidChange:)
		 name:UITextViewTextDidChangeNotification
		 object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setText:(NSString *)text {
	[super setText:text];
	
	[self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
	[super setAttributedText:attributedText];
	
	[self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font {
	[super setFont:font];
	
	[self setNeedsDisplay];
}

- (void)setPlaceHolder:(NSString *)placeHolder {
	_placeHolder = placeHolder;
	
	[self setNeedsDisplay];
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor {
	_placeHolderColor = placeHolderColor;
	
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	
	// 如果没有文本直接返回
	if (self.hasText) {
		return;
	}
	
	// 设置字体属性
	NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
	attrs[NSFontAttributeName] = [UIFont systemFontOfSize:15];
	attrs[NSForegroundColorAttributeName] = self.placeHolderColor ? self.placeHolderColor : [UIColor lightGrayColor];
	
	// 绘画文本
	CGFloat x = 5;
	CGFloat y = 8;
	CGFloat w = rect.size.width - 2 * x;
	CGFloat h = rect.size.height - 2 * y;
	CGRect placeHolderRect = CGRectMake(x, y, w, h);
	[self.placeHolder drawInRect:placeHolderRect withAttributes:attrs];
}

// MARK: - Observer
- (void)textDidChange:(UITextView *)text {
	[self setNeedsDisplay];
}

@end
