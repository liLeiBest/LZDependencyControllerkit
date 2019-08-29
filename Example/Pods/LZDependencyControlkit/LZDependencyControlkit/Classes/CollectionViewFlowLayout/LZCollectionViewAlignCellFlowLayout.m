//
//  LZCollectionViewAlignCellFlowLayout.m
//  LZDependencyControlkit
//
//  Created by Dear.Q on 2019/8/10.
//

#import "LZCollectionViewAlignCellFlowLayout.h"

@implementation LZCollectionViewAlignCellFlowLayout {
	
	CGFloat _sumCellWidthInLine;
}

// MARK: - Initialization
- (instancetype)init {
	
	if (self = [super init]) {
		
		self.scrollDirection = UICollectionViewScrollDirectionVertical;
		self.minimumLineSpacing = 10.0f;
		self.minimumInteritemSpacing = 10.0f;
		self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
	}
	return self;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
	
	NSArray *layoutAttributes = [super layoutAttributesForElementsInRect:rect];
	
	NSMutableArray *layoutAttributes_line = [NSMutableArray array];
	for (NSUInteger index = 0; index < layoutAttributes.count; index++) {
		
		UICollectionViewLayoutAttributes *currentAttrbutes = [layoutAttributes objectAtIndex:index];
		UICollectionViewLayoutAttributes *previousAttributes = 0 == index ? nil : [layoutAttributes objectAtIndex:index - 1];
		UICollectionViewLayoutAttributes *nextAttributes = layoutAttributes.count == index + 1 ? nil : [layoutAttributes objectAtIndex:index + 1];
		[layoutAttributes_line addObject:currentAttrbutes];
		
		_sumCellWidthInLine += CGRectGetWidth(currentAttrbutes.frame);
		
		CGFloat currentY = CGRectGetMaxY(currentAttrbutes.frame);
		CGFloat previouY = nil == previousAttributes ? 0 : CGRectGetMaxY(previousAttributes.frame);
		CGFloat nextY = nil == nextAttributes ? 0 : CGRectGetMaxY(nextAttributes.frame);
		if (currentY != previouY && currentY != nextY) {
			if ([currentAttrbutes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader] ||
				[currentAttrbutes.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]) {
				
				_sumCellWidthInLine = 0;
				[layoutAttributes_line removeAllObjects];
			} else {
				[self adjustCellFrame:layoutAttributes_line];
			}
		} else if (currentY != nextY) {
			[self adjustCellFrame:layoutAttributes_line];
		}
	}
	return layoutAttributes;
}

// MARK: - Private
- (void)adjustCellFrame:(NSMutableArray *)layoutAttributes {
	
	UIEdgeInsets sectionInset = self.sectionInset;
	id<UICollectionViewDelegateFlowLayout> target = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
	UICollectionViewLayoutAttributes *collectionViewLayoutAttributes = [layoutAttributes firstObject];
	NSIndexPath *indexPath = collectionViewLayoutAttributes.indexPath;
	if ([target respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
		sectionInset = [target collectionView:self.collectionView layout:self insetForSectionAtIndex:indexPath.section];
	}
	
	CGFloat interitemSpacing = self.minimumInteritemSpacing;
	if ([target respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
		interitemSpacing = [target collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:indexPath.section];
	}
	
	CGFloat x = 0;
	switch (self.aligment) {
		case LZFlowLayoutCellAlignmentLeft: {
		
			x = sectionInset.left;
			for (UICollectionViewLayoutAttributes * attributes in layoutAttributes) {
				
				CGRect nowFrame = attributes.frame;
				nowFrame.origin.x = x;
				attributes.frame = nowFrame;
				x += nowFrame.size.width + interitemSpacing;
			}
		}
			break;
		case LZFlowLayoutCellAlignmentCenter: {
			
			x = (self.collectionView.frame.size.width - _sumCellWidthInLine - ((layoutAttributes.count - 1) * interitemSpacing)) * 0.5;
			for (UICollectionViewLayoutAttributes * attributes in layoutAttributes) {
				
				CGRect nowFrame = attributes.frame;
				nowFrame.origin.x = x;
				attributes.frame = nowFrame;
				x += nowFrame.size.width + interitemSpacing;
			}
		}
			break;
		case LZFlowLayoutCellAlignmentRight: {
			
			x = self.collectionView.frame.size.width - sectionInset.right;
			for (NSInteger index = layoutAttributes.count - 1 ; index >= 0 ; index-- ) {
				
				UICollectionViewLayoutAttributes * attributes = layoutAttributes[index];
				CGRect nowFrame = attributes.frame;
				nowFrame.origin.x = x - nowFrame.size.width;
				attributes.frame = nowFrame;
				x = x - nowFrame.size.width - interitemSpacing;
			}
		}
			break;
		default:
			break;
	}
	_sumCellWidthInLine = 0.0;
	[layoutAttributes removeAllObjects];
}

@end
