//
//  LZCollectionViewZoomHeaderFlowLayout.m
//  LZDependencyControlkit
//
//  Created by Dear.Q on 2020/2/12.
//

#import "LZCollectionViewZoomHeaderFlowLayout.h"

@implementation LZCollectionViewZoomHeaderFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    UICollectionView *collectionView = [self collectionView];
    UIEdgeInsets insets = [collectionView contentInset];
    CGPoint offset = [collectionView contentOffset];
    CGFloat minY = -insets.top;
    
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    if (offset.y < minY) {
        
        CGSize  headerSize = [self headerReferenceSize];
        CGFloat deltaY = fabs(offset.y - minY);
        for (UICollectionViewLayoutAttributes *attrs in attributes) {
            if ([attrs representedElementKind] == UICollectionElementKindSectionHeader) {
                
                CGRect headerRect = [attrs frame];
                headerRect.size.height = MAX(minY, headerSize.height + deltaY);
                headerRect.origin.y = headerRect.origin.y - deltaY;
                [attrs setFrame:headerRect];
                break;
            }
        }
    }
    return attributes;
}

@end
