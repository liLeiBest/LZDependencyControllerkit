//
//  LZMarqueeLabel.h
//  LZDependencyControllerkit
//
//  Created by Dear.Q on 2020/12/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LZMarqueeLabelType) {
    /// 向左边滚动
    LZMarqueeLabelTypeLeft = 0,
    /// 先向左边，再向右边滚动
    LZMarqueeLabelTypeLeftRight = 1,
};

@interface LZMarqueeLabel : UILabel

@property(nonatomic, unsafe_unretained) LZMarqueeLabelType marqueeLabelType;
/// 速度
@property(nonatomic, unsafe_unretained) CGFloat speed;
@property(nonatomic, unsafe_unretained) CGFloat secondLabelInterval;
/// 滚到顶的停止时间
@property(nonatomic, unsafe_unretained) NSTimeInterval stopTime;

@end

NS_ASSUME_NONNULL_END
