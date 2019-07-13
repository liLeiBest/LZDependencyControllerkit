//
//  LZBadgeButton.h
//  Pods
//
//  Created by Dear.Q on 16/8/12.
//
//

#import "LZNoHighlightButton.h"

UIKIT_EXTERN NSString * const LZBADGE_NONENUMBER;

@interface LZBadgeButton : LZNoHighlightButton

/** 提醒数字 */
@property (nonatomic, copy) NSString *badgeValue;

@end
