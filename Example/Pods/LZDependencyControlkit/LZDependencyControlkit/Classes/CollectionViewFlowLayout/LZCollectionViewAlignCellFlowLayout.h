//
//  LZCollectionViewAlignCellFlowLayout.h
//  LZDependencyControlkit
//
//  Created by Dear.Q on 2019/8/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LZFlowLayoutCellAlignment) {
	LZFlowLayoutCellAlignmentLeft,
	LZFlowLayoutCellAlignmentCenter,
	LZFlowLayoutCellAlignmentRight,
};

@interface LZCollectionViewAlignCellFlowLayout : UICollectionViewFlowLayout

/** 对齐方式 */
@property (nonatomic, assign) LZFlowLayoutCellAlignment aligment;

@end

NS_ASSUME_NONNULL_END
