//
//  LZCollectionViewWaterfallFlowLayout.m
//  3ikidsParents
//
//  Created by liLei on 15/3/28.
//  Copyright (c) 2015年 lilei. All rights reserved.
//

#import "LZCollectionViewWaterfallFlowLayout.h"

@interface LZCollectionViewWaterfallFlowLayout()

/** 存储所有组最大的Y值 */
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *maxYArray;
/** 存储每一列最大的Y值（每一列的宽度） */
@property (nonatomic, strong) NSDictionary *previousMaxYDict;
/** 存储所有布局属性 */
@property (nonatomic, strong) NSMutableArray *attrsArray;

@end

@implementation LZCollectionViewWaterfallFlowLayout

// MARK: - Lazy Loading
- (NSMutableArray *)maxYArray {
    if (nil == _maxYArray) {
        _maxYArray = [[NSMutableArray alloc] init];
    }
    return _maxYArray;
}

- (NSMutableArray *)attrsArray {
    if (nil == _attrsArray) {
        _attrsArray = [[NSMutableArray alloc] init];
    }
    return _attrsArray;
}

// MARK: - Initialization
- (instancetype)init {
    if (self = [super init]) {
        
        // 设置瀑布流默认间距、边距及行数
        self.columnMargin = 10;
        self.rowMargin = 10;
        self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        self.columnsCount = [NSNumber numberWithInteger:3];
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

/**
 *  每次布局之前的准备
 */
- (void)prepareLayout{
    [super prepareLayout];
	
	NSUInteger sectionCount = self.collectionView.numberOfSections;
	
    // 清空最大的 Y 值
	[self.maxYArray removeAllObjects];
    // 清空所有 Cell 的属性
    [self.attrsArray removeAllObjects];
	
	// 计算所有 Cell 的属性
	for (NSUInteger section = 0; section < sectionCount; section++) {
		
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
		UICollectionViewLayoutAttributes *headerLayoutAttributes =
		[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
											 atIndexPath:indexPath];
		if (nil != headerLayoutAttributes) {
			[self.attrsArray addObject:headerLayoutAttributes];
		}
		
		NSUInteger rowCount = [self.collectionView numberOfItemsInSection:section];
		NSMutableDictionary *sectionMaxYDict = [NSMutableDictionary dictionaryWithCapacity:rowCount];
		CGFloat currentMaxY = [self fetchTheCurrentMaxY];
		if (nil == headerLayoutAttributes && 0 == section) {
			currentMaxY += self.sectionInset.top;
		}
		for (NSInteger i = 0; i < [self.columnsCount integerValue]; i++) {
			
			NSString *column = [NSString stringWithFormat:@"%ld", i];
			[sectionMaxYDict setObject:@(currentMaxY) forKey:column];
		}
		[self.maxYArray addObject:sectionMaxYDict];
		
		for (NSInteger row = 0; row < rowCount; row++) {
			
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
			UICollectionViewLayoutAttributes *attrs =
			[self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
			[self.attrsArray addObject:attrs];
		}
		
		UICollectionViewLayoutAttributes *footerLayoutAttributes =
		[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter
											 atIndexPath:indexPath];
		if (nil != footerLayoutAttributes) {
			[self.attrsArray addObject:footerLayoutAttributes];
		}
	}
}

/**
 返回所有内容的宽和高

 @return CGSize
 */
- (CGSize)collectionViewContentSize {
	
	CGFloat height = [self fetchTheCurrentMaxY];
    return CGSizeMake(0, height + self.sectionInset.bottom);
}

/**
 *  返回 indexPath 位置的 Cell 的布局属性
 *
 *  @param indexPath index
 *
 *  @return UICollectionViewLayoutAttributes
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	NSMutableDictionary *maxYDict = [self.maxYArray objectAtIndex:indexPath.section];
	
    // 找出最短Y值所在的列数
    __block NSString *minColumn = @"0";
    [maxYDict enumerateKeysAndObjectsUsingBlock:^(NSString *column, NSNumber *maxY, BOOL *stop) {
        if ([maxY floatValue] < [maxYDict[minColumn] floatValue]) {
            minColumn = column;
        }
    }];
    
    // 计算尺寸
    CGFloat width = (self.collectionView.frame.size.width - self.sectionInset.left - self.sectionInset.right - ([self.columnsCount integerValue] - 1) * self.columnMargin) / [self.columnsCount integerValue];
    CGFloat height = [self.delegate waterfallFlowLayout:self heightForWidth:width atIndexPath:indexPath];
    
    // 计算位置
    CGFloat x = self.sectionInset.left + (width + self.columnMargin) * [minColumn intValue];
	CGFloat y = [maxYDict[minColumn] floatValue];
    
    // 更新最大的Y值
    [maxYDict setObject:@(y + height + self.rowMargin) forKey:minColumn];
    
    // 创建属性
    UICollectionViewLayoutAttributes *cellAttributes =
	[UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    cellAttributes.frame = CGRectMake(x, y, width, height);
    return cellAttributes;
}

/**
 返回 indexPath 位置的 elementKind 的布局属性

 @param elementKind NSString
 @param indexPath NSIndexPath
 @return UICollectionViewLayoutAttributes
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind
																	   atIndexPath:(NSIndexPath *)indexPath {
	
	UICollectionViewLayoutAttributes *supplementaryViewLayoutAttributes =
	[UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind
																   withIndexPath:indexPath];
	
	CGFloat currentMaxY = 0;
	CGFloat height = 0;
	if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
		if (0 < indexPath.section) {
			currentMaxY = [self fetchTheCurrentMaxY];
		} else {
			currentMaxY += self.sectionInset.top;
		}
		if ([self.delegate respondsToSelector:@selector(waterfallFlowLayout:referenceSizeForHeaderInSection:)]) {
			height = [self.delegate waterfallFlowLayout:self referenceSizeForHeaderInSection:indexPath.section].height;
		}
	} else {
		
		currentMaxY = [self fetchTheCurrentMaxY];
		currentMaxY -= self.rowMargin;
		if ([self.delegate respondsToSelector:@selector(waterfallFlowLayout:referenceSizeForFooterInSection:)]) {
			height = [self.delegate waterfallFlowLayout:self referenceSizeForFooterInSection:indexPath.section].height;
		}
	}
	supplementaryViewLayoutAttributes.frame = CGRectMake(0, currentMaxY, self.collectionView.frame.size.width, height);
	return supplementaryViewLayoutAttributes;
}

/**
 返回rect范围内的布局属性

 @param rect CGRect
 @return NSArray
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrsArray;
}

// MARK: - Private
/**
 获取当前最大的 Y 值

 @return CGFloat
 */
- (CGFloat)fetchTheCurrentMaxY {
	
	CGFloat maxY = 0;
	UICollectionViewLayoutAttributes *layoutAttributes = [self.attrsArray lastObject];
	if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader] ||
		[layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]) {
		maxY = CGRectGetMaxY(layoutAttributes.frame);
	} else {
		
		NSMutableDictionary *maxYDict = [self.maxYArray lastObject];
		__block NSString *maxColumn = @"0";
		[maxYDict enumerateKeysAndObjectsUsingBlock:^(NSString *column, NSNumber *maxY, BOOL *stop) {
			if ([maxY floatValue] > [maxYDict[maxColumn] floatValue]) {
				maxColumn = column;
			}
		}];
		if (0 < maxYDict.count) {
			maxY = [maxYDict[maxColumn] floatValue];
		}
	}
	return maxY;
}

@end
