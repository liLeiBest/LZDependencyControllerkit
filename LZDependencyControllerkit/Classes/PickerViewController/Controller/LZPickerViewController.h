//
//  LZPickerViewController.h
//  LZDependencyControllerkit
//
//  Created by Dear.Q on 2020/2/27.
//

#import <UIKit/UIKit.h>
@class LZPickerViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol LZPickerViewControllerDataSource <NSObject>

@required
///  要显示的列数
/// @param pickerVC  LZPickerViewController
- (NSInteger)numberOfComponentsInPickerViewController:(LZPickerViewController *)pickerVC;

/// 要显示每一列的行数
/// @param pickerVC  LZPickerViewController
/// @param component  NSInteger
/// @param indexArray NSArray，下标：行；值：列（NSNumber）
- (NSInteger)pickerViewController:(LZPickerViewController *)pickerVC
          numberOfRowsInComponent:(NSInteger)component
               selectedIndexArray:(NSArray *)indexArray;

@end
@protocol LZPickerViewControllerDelegate <NSObject>

@optional
/// 要显示的所在列的每一行的标题
/// @param pickerVC  LZPickerViewController
/// @param row  NSInteger
/// @param component  NSInteger
/// @param indexArray NSArray，下标：行；值：列（NSNumber）
- (nullable NSString *)pickerViewController:(LZPickerViewController *)pickerVC
                                titleForRow:(NSInteger)row
                               forComponent:(NSInteger)component
                         selectedIndexArray:(NSArray *)indexArray;

/// 选中了某列某行
/// @param pickerVC  LZPickerViewController
/// @param indexArray NSArray，下标：行；值：列（NSNumber）
- (void)pickerViewController:(LZPickerViewController *)pickerVC
       didSelectedIndexArray:(NSArray *)indexArray;

/// 点击了完成
/// @param pickerVC  LZPickerViewController
/// @param indexArray NSArray，下标：行；值：列（NSNumber）
- (void)pickerViewController:(LZPickerViewController *)pickerVC
   didDoneSelectedIndexArray:(NSArray *)indexArray;

@optional

@end

@interface LZPickerViewController : UIViewController

/// 数据源
@property (nonatomic, weak) id<LZPickerViewControllerDataSource> dataSource;
/// 代理
@property (nonatomic, weak) id<LZPickerViewControllerDelegate> delegate;
/// 标题，默认 nil
@property (nonatomic, copy) NSString *pickerTitle;
/// 工具栏按钮字体颜色
@property (nonatomic, strong) UIColor *toolbarTitleColor;
/// 工具栏按钮字体颜色
@property (nonatomic, strong) UIColor *pickerSeperatorColor;
/// 选中的索引
@property (nonatomic, strong) NSArray *selectedIndexs;


/// 实例
+ (instancetype)instance;

/// 展示
/// @param sender  UIViewController
- (void)showPickerVC:(UIViewController *)sender;

@end

NS_ASSUME_NONNULL_END
