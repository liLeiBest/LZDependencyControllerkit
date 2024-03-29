//
//  LZPickerViewController.m
//  LZDependencyControllerkit
//
//  Created by Dear.Q on 2020/2/27.
//

#import "LZPickerViewController.h"
#import <LZDependencyToolkit/LZDependencyToolkit.h>

@interface LZPickerViewController ()
<LZModalPresentationTranslucentTransitioningDelegate, UIViewControllerTransitioningDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIView *toolbarView;
@property (nonatomic, weak) IBOutlet UIButton *cancleBtn;
@property (nonatomic, weak) IBOutlet UIButton *titleBtn;
@property (nonatomic, weak) IBOutlet UIButton *confirmBtn;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *pickerViewBottom;

@property (nonatomic, strong) NSArray *lastSelectedIndex;
@property (nonatomic, strong) NSMutableArray *indexDataSource;

@end
@implementation LZPickerViewController

// MARK: - Lazy Loading
- (NSMutableArray *)indexDataSource {
    if (nil == _indexDataSource) {
        _indexDataSource = [NSMutableArray array];
    }
    return _indexDataSource;
}

// MARK: - Initialization
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.containerView roundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight radius:self.corner];
}

- (void)dealloc {
    LZLog();
}

- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationCustom;
}

- (id<UIViewControllerTransitioningDelegate>)transitioningDelegate {
    return self;
}

// MARK: - Public
+ (instancetype)instance {
    return [self viewControllerFromstoryboard:@"LZPickerViewController"
                                     inBundle:@"LZPickerViewController"];
}

- (void)showPickerVC:(UIViewController *)sender {
    [sender presentViewController:self animated:YES completion:nil];
}

// MARK: - UI Action
- (IBAction)cancleDidTouch:(UIButton *)sender {
    
    [self closePickerView];
    if (self.lastSelectedIndex && self.lastSelectedIndex.count) {
        
        [self.indexDataSource removeAllObjects];
        [self.indexDataSource addObjectsFromArray:self.lastSelectedIndex];
        SEL selector = @selector(pickerViewController:didSelectedIndexArray:);
        if ([self.delegate respondsToSelector:selector]) {
            [self.delegate pickerViewController:self didSelectedIndexArray:self.indexDataSource];
        }
    }
}

- (IBAction)confirmDidTouch:(UIButton *)sender {
    
    SEL selector = @selector(pickerViewController:didDoneSelectedIndexArray:);
    if ([self.delegate respondsToSelector:selector]) {
        [self.delegate pickerViewController:self didDoneSelectedIndexArray:self.indexDataSource];
    }
    [self closePickerView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self closePickerView];
}

// MAKR: - Private
- (void)setupUI {
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f];
    
    [self configToolBar];
    [self configPickerView];
}

- (void)configToolBar {
    
    UIColor *textColor = self.toolbarTitleColor ?: [UIColor colorWithHexString:@"#333333"];
    [self.cancleBtn setTitleColor:textColor forState:UIControlStateNormal];
    [self.titleBtn setTitleColor:textColor forState:UIControlStateNormal];
    [self.titleBtn setTitle:self.pickerTitle forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:textColor forState:UIControlStateNormal];
}

- (void)configPickerView {
    
    self.pickerViewBottom.constant = LZAppUnit.safeAreaInsets().bottom;
    [self.view layoutIfNeeded];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    if (self.selectedIndexs && self.selectedIndexs.count) {
        
        self.lastSelectedIndex = self.selectedIndexs;
        [self.indexDataSource addObjectsFromArray:self.selectedIndexs];
    }
    for (NSInteger i = 0; i < self.selectedIndexs.count; i++) {
        
        NSInteger component = i;
        NSInteger row = [self.selectedIndexs[i] integerValue];
        [self.pickerView selectRow:row inComponent:component animated:YES];
    }
}

- (void)changeSpearatorLineColor {
    if (self.pickerSeperatorColor) {
        for (UIView *speartorView in self.pickerView.subviews) {
            if (speartorView.frame.size.height < 1) {
                speartorView.backgroundColor = self.pickerSeperatorColor;
            }
        }
    }
}

- (void)closePickerView {
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.view.alpha = 0.0;
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}


// MARK: - Delegate
// MARK: <LZModalPresentationTranslucentTransitioningDelegate>
- (UIView *)contentViewInModalPresentationTranslucentTransitioning:(LZModalPresentationTranslucentTransitioning *)addressPickerTransition {
    return self.containerView;
}

// MARK: <UIViewControllerTransitioningDelegate>
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    LZModalPresentationTranslucentTransitioning *transitioning = [[LZModalPresentationTranslucentTransitioning alloc] initWithType:LZModalPresentationTypeShow];
    transitioning.delegate = self;
    return transitioning;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    LZModalPresentationTranslucentTransitioning *transitioning = [[LZModalPresentationTranslucentTransitioning alloc] initWithType:LZModalPresentationTypeDismiss];
    transitioning.delegate = self;
    return transitioning;
}

// MARK: <UIPickerViewDataSource>
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if ([self.dataSource respondsToSelector:@selector(numberOfComponentsInPickerViewController:)]) {
        
        NSInteger components = [self.dataSource numberOfComponentsInPickerViewController:self];
        if (0 < self.indexDataSource.count && components != self.indexDataSource.count) {
            [self.indexDataSource removeAllObjects];
        }
        if (0 == self.indexDataSource.count) {
            for (NSInteger i = 0; i < components; i++) {
                [self.indexDataSource addObject:@(0)];
            }
        }
        return components;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    
    SEL selector = @selector(pickerViewController:numberOfRowsInComponent:selectedIndexArray:);
    if ([self.dataSource respondsToSelector:selector]) {
        return [self.dataSource pickerViewController:self
                             numberOfRowsInComponent:component
                                  selectedIndexArray:self.indexDataSource];
    }
    return 0;
}

// MARK: <UIPickerViewDelegate>
- (nullable NSString *)pickerView:(UIPickerView *)pickerView
                      titleForRow:(NSInteger)row
                     forComponent:(NSInteger)component  {
    
    SEL selector = @selector(pickerViewController:titleForRow:forComponent:selectedIndexArray:);
    if ([self.delegate respondsToSelector:selector]) {
        return [self.delegate pickerViewController:self
                                       titleForRow:row
                                      forComponent:component
                                selectedIndexArray:self.indexDataSource];
    }
    return @"";
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(nullable UIView *)view {

    [self changeSpearatorLineColor];
    UILabel *label = (id)view;
    if (!label) {

        label= [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
    }
    
    SEL selector = @selector(pickerViewController:titleForRow:forComponent:selectedIndexArray:);
    if ([self.delegate respondsToSelector:selector]) {
        label.text = [self.delegate pickerViewController:self
                                             titleForRow:row
                                            forComponent:component
                                      selectedIndexArray:self.indexDataSource];
    }
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    // 更新选中的行
    for (NSUInteger column = 0; column < self.indexDataSource.count; column++) {
        if (column == component) {
            [self.indexDataSource replaceObjectAtIndex:column withObject:@(row)];
        } else if (column > component) {
            
            [self.indexDataSource replaceObjectAtIndex:column withObject:@(0)];
            [pickerView reloadComponent:column];
            [pickerView selectRow:0 inComponent:column animated:YES];
        }
    }
    
    SEL selector = @selector(pickerViewController:didSelectedIndexArray:);
    if ([self.delegate respondsToSelector:selector]) {
        [self.delegate pickerViewController:self didSelectedIndexArray:self.indexDataSource];
    }
}

@end
