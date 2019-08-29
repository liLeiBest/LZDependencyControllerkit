//
//  LZSegmentControl.h
//  LZDependencyControlkit
//
//  Created by Dear.Q on 2019/8/10.
//

#import <UIKit/UIKit.h>
#import "LZSegmentItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LZSegmentControl : UIView

/** 选中回调 */
@property (copy, nonatomic) void (^itemDidSelectedCallback)(LZSegmentItemModel *itemModel);

//- (instancetype)initWithFrame:(CGRect)frame;
- (void)updateItems:(NSArray<LZSegmentItemModel *> *)items;
- (void)insertItem:(LZSegmentItemModel *)item atIndex:(NSUInteger)index;
- (void)updateSeletedItemByIndex:(NSUInteger)index;
@end

NS_ASSUME_NONNULL_END
