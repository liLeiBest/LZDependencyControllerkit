//
//  LZSegmentItemCell.h
//  LZDependencyControlkit
//
//  Created by Dear.Q on 2019/8/13.
//

#import <UIKit/UIKit.h>
@class LZSegmentItemModel;

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString * const LZSegmentItemCellIdentify;

@interface LZSegmentItemCell : UICollectionViewCell

@property (strong, nonatomic) LZSegmentItemModel *itemModel;

@end

NS_ASSUME_NONNULL_END
