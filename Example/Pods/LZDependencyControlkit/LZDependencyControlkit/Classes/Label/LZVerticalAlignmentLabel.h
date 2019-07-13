//
//  LZVerticalAlignmentLabel.h
//  Pods
//
//  Created by lilei on 2017/7/6.
//  
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, VerticalAlignment) {
	VerticalAlignmentTop = 0, // default
	VerticalAlignmentMiddle,
	VerticalAlignmentBottom,
};

@interface LZVerticalAlignmentLabel : UILabel

@property (nonatomic, assign) VerticalAlignment verticalAlignment;

@end
