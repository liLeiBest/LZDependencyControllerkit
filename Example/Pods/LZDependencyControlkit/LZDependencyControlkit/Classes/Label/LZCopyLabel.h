//
//  LZCopyLabel.h
//  LZDependencyControlkit
//
//  Created by Dear.Q on 2019/6/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LZCopyLabel : UILabel

/** 选中文本的背景色 */
@property (strong, nonatomic) UIColor *selectedBgColor;
/** 复制菜单的名称，默认 拷贝 */
@property (copy, nonatomic) NSString *menuTitle;

@end

NS_ASSUME_NONNULL_END
