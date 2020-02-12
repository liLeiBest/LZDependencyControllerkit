//
//  LZFixedButton.h
//  LZDependencyControlkit
//
//  Created by Dear.Q on 2020/2/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, LZFixedButtonTitlePosition) {
    LZFixedButtonTitlePositionTop,
    LZFixedButtonTitlePositionLeft,
    LZFixedButtonTitlePositionBottom,
};

@interface LZFixedButton : UIButton

@property (nonatomic, assign) LZFixedButtonTitlePosition titlePosition;
@property (nonatomic, assign) CGFloat titleProportionInButton;


@end

NS_ASSUME_NONNULL_END
