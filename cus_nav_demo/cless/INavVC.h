//
//  INavVC.h
//  cus_nav_demo
//
//  Created by LiRui on 15/11/30.
//  Copyright © 2015年 Lirui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+INavVC.h"


typedef void (^CusNavAniCom)(void);



@interface INavVC : UIViewController

//使用 remove push pop 操作viewControllers
@property(atomic, strong) NSMutableArray *viewControllers;

@property(nonatomic, strong, readonly) UIViewController *rootVC;
//使用此方法初始化
- (instancetype) initWithRootVC:(UIViewController*)rootVC;
//动画结束后才能移除，并且不能移除topVC
- (void) removeVC:(UIViewController*)removeVC;

- (void) pushVC:(UIViewController *)viewController;
- (void) pushVC:(UIViewController *)viewController com:(CusNavAniCom)com;

- (void) popVC;
- (void) popVCWithCom:(CusNavAniCom)com;

- (void) popToRootVC;
- (void) popToRootVCWithCom:(CusNavAniCom)com;

@end
