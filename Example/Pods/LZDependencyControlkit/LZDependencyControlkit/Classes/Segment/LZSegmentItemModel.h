//
//  LZSegmentItemModel.h
//  LZDependencyControlkit
//
//  Created by Dear.Q on 2019/8/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LZSegmentItemModel : NSObject

@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) NSUInteger index;


/**
 快速构造方法

 @param title 标题
 @param index 索引
 @return LZSegmentItemModel 对象
 */
+ (instancetype)itemWithTitle:(NSString *)title
					  atIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
