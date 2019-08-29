//
//  LZSegmentItemCell.m
//  LZDependencyControlkit
//
//  Created by Dear.Q on 2019/8/13.
//

#import "LZSegmentItemCell.h"
#import "LZSegmentItemModel.h"

NSString * const LZSegmentItemCellIdentify = @"LZSegmentItemCell";
@implementation LZSegmentItemCell {
	
	IBOutlet UILabel *titleLabel;
}

// MARK: - Initialization
- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self setupUI];
}

- (void)setItemModel:(LZSegmentItemModel *)itemModel {
	_itemModel = itemModel;
	
	titleLabel.text = itemModel.title;
}

// MARK: - Private
- (void)setupUI {
	
}

@end
