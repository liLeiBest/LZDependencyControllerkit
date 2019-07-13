//
//  LZTextView.h
//  LZDependencyControlkit
//
//  Created by Dear.Q on 2019/6/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LZTextView : UITextView

/** 提示文本 */
@property (nonatomic, copy) NSString *placeHolder;
/** 提示文本颜色 */
@property (nonatomic, strong) UIColor *placeHolderColor;

@end

NS_ASSUME_NONNULL_END
