//
//  LZSegmentItemModel.m
//  LZDependencyControlkit
//
//  Created by Dear.Q on 2019/8/10.
//

#import "LZSegmentItemModel.h"

@implementation LZSegmentItemModel

// MARK: - Public
+ (instancetype)itemWithTitle:(NSString *)title atIndex:(NSUInteger)index {
	
	LZSegmentItemModel *itemModel = [[LZSegmentItemModel alloc] init];
	itemModel.title = title;
	itemModel.index = index;
	return itemModel;
}
@end
