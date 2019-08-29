//
//  LZCollectionViewWaterfallFlowLayout.h
//  3ikidsParents
//
//  Created by liLei on 15/3/28.
//  Copyright (c) 2015年 lilei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LZCollectionViewWaterfallFlowLayout;
@protocol LZCollectionViewWaterfallFlowLayoutDelegate <NSObject>

@required

/**
 *  返回indexPath对应的高宽比（宽度）
 *
 *  @param flowLayout LZCollectionViewWaterfallFlowLayout
 *  @param width           宽度
 *  @param indexPath       indexPath
 *
 *  @return 高宽比（宽度）
 */
- (CGFloat)waterfallFlowLayout:(LZCollectionViewWaterfallFlowLayout *)flowLayout
				heightForWidth:(CGFloat)width
				   atIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 返回 Header 的大小

 @param flowLayout LZCollectionViewWaterfallFlowLayout
 @param section NSInteger
 @return CGSize
 */
- (CGSize)waterfallFlowLayout:(LZCollectionViewWaterfallFlowLayout *)flowLayout
referenceSizeForHeaderInSection:(NSInteger)section;

/**
 返回 Footer 的大小
 
 @param flowLayout LZCollectionViewWaterfallFlowLayout
 @param section NSInteger
 @return CGSize
 */
- (CGSize)waterfallFlowLayout:(LZCollectionViewWaterfallFlowLayout *)flowLayout
referenceSizeForFooterInSection:(NSInteger)section;

@end
@interface LZCollectionViewWaterfallFlowLayout : UICollectionViewLayout

/** 每一行间距 */
@property (nonatomic, assign) CGFloat rowMargin;
/** 每一列间距 */
@property (nonatomic, assign) CGFloat columnMargin;
/** 显示多少列 */
@property (nonatomic, copy) NSNumber *columnsCount;
/** 上左下右的边距 */
@property (nonatomic, assign) UIEdgeInsets sectionInset;


/** 代理 */
@property (nonatomic, weak) id<LZCollectionViewWaterfallFlowLayoutDelegate> delegate;

@end
