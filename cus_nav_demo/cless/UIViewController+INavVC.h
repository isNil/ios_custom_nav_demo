//
//  UIViewController+INavVC.h
//  cus_nav_demo
//
//  Created by LiRui on 15/12/1.
//  Copyright © 2015年 Lirui. All rights reserved.
//

#import <UIKit/UIKit.h>
@class INavVC;



@interface UIViewController (INavVC)


-(INavVC *)navVC;


-(void)setNeedsNavVCStatusBarAppearanceUpdate;






@end
