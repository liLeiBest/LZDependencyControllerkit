//
//  LZSegmentControl.m
//  LZDependencyControlkit
//
//  Created by Dear.Q on 2019/8/10.
//

#import "LZSegmentControl.h"
#import "UIView+LZExtension.h"
#import "NSBundle+LZExtension.h"
#import "LZSegmentItemCell.h"

/** 最小宽度 */
static CGFloat MinSegmentWidth = 80.0f;
@interface LZSegmentControl()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
	
	IBOutlet UIView *containerView;
	IBOutlet UICollectionView *itemCollectionView;
	IBOutlet UIView *lineView;
}

@property (strong, nonatomic) NSMutableArray *datasource;

@end
@implementation LZSegmentControl

// MARK: - Lazy Loading
- (NSMutableArray *)datasource {
	if (nil == _datasource) {
		_datasource = [NSMutableArray array];
	}
	return _datasource;
}

// MARK: - Initialization
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self reuseViewFromXib:@"LZSegmentControl" inBundle:nil];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self = [self reuseViewFromXib:@"LZSegmentControl" inBundle:nil];
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self setupUI];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
}

// MARK: - Public
- (void)updateItems:(NSArray<LZSegmentItemModel *> *)items {
	
	[self.datasource removeAllObjects];
	[self.datasource addObjectsFromArray:items];
	[self refreshSegmentList];
}

- (void)insertItem:(LZSegmentItemModel *)item atIndex:(NSUInteger)index {
	
	[self.datasource insertObject:item atIndex:index];
	[self refreshSegmentList];
}

- (void)updateSeletedItemByIndex:(NSUInteger)index {
	
}

// MARK: - Private
- (void)setupUI {
	
	containerView.backgroundColor = [UIColor orangeColor];
	itemCollectionView.backgroundColor = [UIColor clearColor];
	UINib *cellNib =
	[NSBundle nib:LZSegmentItemCellIdentify inBundle:nil referenceClass:LZSegmentItemCellIdentify];
	[itemCollectionView registerNib:cellNib forCellWithReuseIdentifier:LZSegmentItemCellIdentify];
}

- (void)refreshSegmentList {
	
	[itemCollectionView reloadData];
}

- (CGFloat)caclFixedMaxItemWidth {
	
	return 10;
}

// MARK: - Delegate
// MARK: <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
	 numberOfItemsInSection:(NSInteger)section {
	return self.datasource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	LZSegmentItemCell *cell =
	[collectionView dequeueReusableCellWithReuseIdentifier:LZSegmentItemCellIdentify
											  forIndexPath:indexPath];
	cell.itemModel = [self.datasource objectAtIndex:indexPath.row];
	cell.contentView.backgroundColor =
	[UIColor colorWithRed:(arc4random()%255)/255.0
					green:(arc4random()%255)/255.0
					 blue:(arc4random()%255)/255.0
					alpha:1];
	return cell;
}

// MARK: <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	
	LZSegmentItemModel *itemModel = [self.datasource objectAtIndex:indexPath.row];
	if (self.itemDidSelectedCallback) {
		self.itemDidSelectedCallback(itemModel);
	}
}

// MARK: <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	return CGSizeMake(MinSegmentWidth, collectionView.frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
				   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
				   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	return 0.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
						layout:(UICollectionViewLayout *)collectionViewLayout
		insetForSectionAtIndex:(NSInteger)section {
	return UIEdgeInsetsMake(0, 0, 0, 0);
}

// MARK: <>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
}

@end
