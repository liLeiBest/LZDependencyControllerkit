//
//  LZTestWebJSViewController.m
//  LZDependencyControllerkit_Example
//
//  Created by Dear.Q on 2020/2/13.
//  Copyright © 2020 lilei_hapy@163.com. All rights reserved.
//

#import "LZTestWebJSViewController.h"

@interface LZTestWebJSViewController ()

@end

@implementation LZTestWebJSViewController

- (void)loadView {
    [super loadView];
    
     NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
        NSURL *baseURL = [[NSBundle mainBundle] bundleURL];
        [self.webView loadHTMLString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] baseURL:baseURL];
    //    [self.webView loadHTMLString:@"<html><title>Dialog</title><style type='text/css'>body{font-size:60px}</style><script type='text/javascript'>function myconfirm(){if(confirm('Star it?')){alert('Done')}}</script><body><a href=\"javascript:alert('Just Alert')\" >Alert</a><br /><a href=\"javascript:myconfirm()\">Logout</a></body></html>" baseURL:nil];
    
    self.progressColor = [UIColor blackColor];
    self.progressTrackColor = [UIColor redColor];
    self.displayRefresh = YES;
    self.displayEmptyPage = YES;
    self.rotationLandscape = NO;
    self.showWebTitle = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self nativeInvokeJS:@"showMobile"
       completionHandler:nil];
    
    [self JSInvokeNative:@"showMobile" completionHandler:^(id message) {
        NSLog(@"%@", message);
    }];
    
    [self JSInvokeNative:@"showName" completionHandler:^(id message) {
        NSLog(@"%@", message);
    }];
    
    [self JSInvokeNative:@"showSendMsg" completionHandler:^(id message) {
        NSLog(@"%@", message);
    }];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Right"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(invokeJS)];
}

- (void)invokeJS {
    
    UIAlertController *alertVC =
    [UIAlertController alertControllerWithTitle:@"OC TO JS"
                                        message:@"Native 调用 JS"
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *clear =
    [UIAlertAction actionWithTitle:@"Clear"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * _Nonnull action) {
        
        [self nativeInvokeJS:@"clear()"
           completionHandler:^(id response, NSError *error) {
            NSLog(@"%@", response);
        }];
    }];
    [alertVC addAction:clear];
    
    UIAlertAction *alertMobile =
    [UIAlertAction actionWithTitle:@"AlertMobile"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * _Nonnull action) {
        
        [self nativeInvokeJS:@"alertMobile()"
           completionHandler:^(id response, NSError *error) {
            NSLog(@"%@", response);
        }];
    }];
    [alertVC addAction:alertMobile];
    
    UIAlertAction *alertName =
    [UIAlertAction actionWithTitle:@"AlertMobile"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * _Nonnull action) {
        
        [self nativeInvokeJS:@"alertName('李蕾')"
           completionHandler:^(id response, NSError *error) {
            NSLog(@"%@", response);
        }];
    }];
    [alertVC addAction:alertName];
    
    UIAlertAction *alertSendMsg =
    [UIAlertAction actionWithTitle:@"SendMsg"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * _Nonnull action) {
        
        [self nativeInvokeJS:@"alertSendMsg('李蕾','看电影')"
           completionHandler:^(id response, NSError *error) {
            NSLog(@"%@", response);
        }];
    }];
    [alertVC addAction:alertSendMsg];
    
    UIAlertAction *cancle =
    [UIAlertAction actionWithTitle:@"Cancle"
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVC addAction:cancle];
    [self.navigationController presentViewController:alertVC animated:YES completion:nil];
}

@end
