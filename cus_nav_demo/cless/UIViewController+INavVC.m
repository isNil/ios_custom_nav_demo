//
//  UIViewController+INavVC.m
//  cus_nav_demo
//
//  Created by LiRui on 15/12/1.
//  Copyright © 2015年 Lirui. All rights reserved.
//

#import "UIViewController+INavVC.h"
#import "INavVC.h"

@implementation UIViewController (INavVC)


-(INavVC *)navVC
{
    if([self.parentViewController isKindOfClass:[INavVC class]]){
        return (INavVC*)self.parentViewController;
    }
    else if([self.parentViewController isKindOfClass:[UINavigationController class]] &&
            [self.parentViewController.parentViewController isKindOfClass:[INavVC class]]){
        return (INavVC *)[self.parentViewController parentViewController];
    }
    else{
        return nil;
    }
}


-(void)setNeedsNavVCStatusBarAppearanceUpdate
{
    INavVC * nav = self.navVC;
    if (nav) {
        [nav setNeedsStatusBarAppearanceUpdate];
    } else {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}




@end
