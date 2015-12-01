//
//  INavVC.m
//  cus_nav_demo
//
//  Created by LiRui on 15/11/30.
//  Copyright © 2015年 Lirui. All rights reserved.
//

#import "INavVC.h"


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static const CGFloat kAnimationDuration = 0.3f;
static const CGFloat kAnimationDelay = 0.0f;
static const CGFloat kMaxBlackMaskAlpha = 0.8f;


//滑动方向  用于left_menu
typedef NS_ENUM(NSInteger,PanDirection){
    PanDirectionNone = 0,
    PanDirectionLeft = 1,
    PanDirectionRight = 2
};

@interface INavVC ()<UIGestureRecognizerDelegate>

@property(nonatomic,strong)NSMutableArray *gestures;
@property(nonatomic,strong)UIView *blackMask;
@property(nonatomic,assign)CGPoint panOrigin;
@property(nonatomic,assign)BOOL animationInProgress;
@property(nonatomic,assign)CGFloat percentageOffsetFromLeft;

- (void) addPanGestureToView:(UIView*)view;
- (void) rollBackViewController;

- (UIViewController *)currentViewController;
- (UIViewController *)previousViewController;

- (void) transformAtPercentage:(CGFloat)percentage ;
- (void) completeSlidingAnimationWithDirection:(PanDirection)direction;
- (void) completeSlidingAnimationWithOffset:(CGFloat)offset;
- (CGRect) getSlidingRectWithPercentageOffset:(CGFloat)percentage orientation:(UIInterfaceOrientation)orientation ;
- (CGRect) viewBoundsWithOrientation:(UIInterfaceOrientation)orientation;

@end



@implementation INavVC


#pragma mark - init

- (instancetype) initWithRootVC:(UIViewController*)rootVC
{
    if (self = [super init]) {
        _viewControllers = [NSMutableArray arrayWithObject:rootVC];
    }
    return self;
}

-(void)dealloc
{
    self.viewControllers = nil;
    self.gestures  = nil;
    self.blackMask = nil;
}

-(void)loadView
{
    [super loadView];
    
    CGRect viewRect = [self viewBoundsWithOrientation:self.interfaceOrientation];
    
    UIViewController *rootViewController = [self.viewControllers objectAtIndex:0];
    [rootViewController willMoveToParentViewController:self];
    [self addChildViewController:rootViewController];
    
    UIView * rootView = rootViewController.view;
    rootView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    rootView.frame = viewRect;
    [self.view addSubview:rootView];
    [rootViewController didMoveToParentViewController:self];
    _blackMask = [[UIView alloc] initWithFrame:viewRect];
    _blackMask.backgroundColor = [UIColor blackColor];
    _blackMask.alpha = 0.0;
    _blackMask.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:_blackMask atIndex:0];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

}


#pragma mark - public

//动画结束后才能移除，并且不能移除topVC
- (void) removeVC:(UIViewController*)removeVC
{
    if ([self.viewControllers lastObject] != removeVC) {
        [self.viewControllers removeObject:removeVC];
    }
}

- (void) pushVC:(UIViewController *)viewController
{
    [self pushVC:viewController com:^{
        
    }];
}

- (void) pushVC:(UIViewController *)viewController com:(CusNavAniCom)com
{
    _animationInProgress = YES;
    viewController.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
    viewController.view.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _blackMask.alpha = 0.0;
    [viewController willMoveToParentViewController:self];
    [self addChildViewController:viewController];
    [self.view bringSubviewToFront:_blackMask];
    [self.view addSubview:viewController.view];
    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:0 animations:^{
        CGAffineTransform transf = CGAffineTransformIdentity;
        [self currentViewController].view.transform = CGAffineTransformScale(transf, 0.9f, 0.9f);
        viewController.view.frame = self.view.bounds;
        _blackMask.alpha = kMaxBlackMaskAlpha;
    }completion:^(BOOL finished) {
        if (finished) {
            [self.viewControllers addObject:viewController];
            [viewController didMoveToParentViewController:self];
            _animationInProgress = NO;
            _gestures = [[NSMutableArray alloc] init];
            [self addPanGestureToView:[self currentViewController].view];
            com();
        }
    }];

}

- (void) popVC
{
    [self popVCWithCom:^{
        
    }];

}

- (void) popVCWithCom:(CusNavAniCom)com
{
    _animationInProgress = YES;
    if (self.viewControllers.count < 2) {
        return;
    }
    
    UIViewController *currentVC = [self currentViewController];
    UIViewController *previousVC = [self previousViewController];
    [previousVC viewWillAppear:NO];
    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:0 animations:^{
        currentVC.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
        CGAffineTransform transf = CGAffineTransformIdentity;
        previousVC.view.transform = CGAffineTransformScale(transf, 1.0, 1.0);
        previousVC.view.frame = self.view.bounds;
        _blackMask.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [currentVC.view removeFromSuperview];
            [currentVC willMoveToParentViewController:nil];
            [self.view bringSubviewToFront:[self previousViewController].view];
            [currentVC removeFromParentViewController];
            [currentVC didMoveToParentViewController:nil];
            [self.viewControllers removeObject:currentVC];
            _animationInProgress = NO;
            [previousVC viewDidAppear:NO];
            com();
        }
    }];

}

- (void) popToRootVC
{
    [self popToRootVCWithCom:^{
        
    }];
}

- (void) popToRootVCWithCom:(CusNavAniCom)com
{
    _animationInProgress = YES;
    if (self.viewControllers.count < 2) {
        return;
    }
    
    UIViewController *currentVC = [self currentViewController];
    
    int count = (int)self.viewControllers.count;
    for (int i=1; i<count-1; i++) {
        UIViewController * model = [self.viewControllers objectAtIndex:i];
        [model.view removeFromSuperview];
    }
    
    
    UIViewController * rootVC = [self rootViewController];
    CGAffineTransform transf = CGAffineTransformIdentity;
    rootVC.view.frame = self.view.bounds;
    rootVC.view.transform = CGAffineTransformScale(transf, 0.9f, 0.9f);
    
    
    [rootVC viewWillAppear:NO];
    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:0 animations:^{
        currentVC.view.frame = CGRectOffset(self.view.bounds, self.view.bounds.size.width, 0);
        CGAffineTransform transf = CGAffineTransformIdentity;
        rootVC.view.transform = CGAffineTransformScale(transf, 1.0, 1.0);
        rootVC.view.frame = self.view.bounds;
        _blackMask.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [currentVC.view removeFromSuperview];
            [currentVC willMoveToParentViewController:nil];
            [self.view bringSubviewToFront:[self previousViewController].view];
            [currentVC removeFromParentViewController];
            [currentVC didMoveToParentViewController:nil];
            [self.viewControllers removeObject:currentVC];
            _animationInProgress = NO;
            [rootVC viewDidAppear:NO];
            com();
        }
    }];
    self.viewControllers = [NSMutableArray arrayWithObject:rootVC];
}







#pragma mark - private

-(UIViewController *)rootVC
{
    if (self.viewControllers && (self.viewControllers.count>0)) {
        return [self.viewControllers firstObject];
    }
    return nil;
}


//手势结束后  最后滚动效果
- (void) rollBackViewController {
    _animationInProgress = YES;
    
    UIViewController * vc = [self currentViewController];
    UIViewController * nvc = [self previousViewController];
    CGRect rect = CGRectMake(0, 0, vc.view.frame.size.width, vc.view.frame.size.height);
    
    [UIView animateWithDuration:kAnimationDuration delay:kAnimationDelay options:0 animations:^{
        CGAffineTransform transf = CGAffineTransformIdentity;
        nvc.view.transform = CGAffineTransformScale(transf, 0.9f, 0.9f);
        vc.view.frame = rect;
        _blackMask.alpha = kMaxBlackMaskAlpha;
    }   completion:^(BOOL finished) {
        if (finished) {
            _animationInProgress = NO;
        }
    }];
}



#pragma mark - ChildViewController
- (UIViewController *)currentViewController {
    UIViewController *result = nil;
    if ([self.viewControllers count]>0) {
        result = [self.viewControllers lastObject];
    }
    return result;
}

#pragma mark - ParentViewController
- (UIViewController *)previousViewController {
    UIViewController *result = nil;
    if ([self.viewControllers count]>1) {
        result = [self.viewControllers objectAtIndex:self.viewControllers.count - 2];
    }
    return result;
}

#pragma mark -root VC-
- (UIViewController *)rootViewController{
    UIViewController * result = nil;
    if ([self.viewControllers count]>1) {
        result = [self.viewControllers firstObject];
    }
    return result;
}


#pragma mark - Add Pan Gesture
- (void) addPanGestureToView:(UIView*)view
{
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(gestureRecognizerDidPan:)];
    panGesture.cancelsTouchesInView = YES;
    panGesture.delegate = self;
    [view addGestureRecognizer:panGesture];
    [_gestures addObject:panGesture];
    panGesture = nil;
}

# pragma mark - Avoid Unwanted Vertical Gesture
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    return fabs(translation.x) > fabs(translation.y) ;
}

#pragma mark - Gesture recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIViewController * vc =  [self.viewControllers lastObject];
    
//    if (vc.needNotHandlePanGestureRecognizer) {
//        return NO;
//    }
    
    //多余一个手指的手势不再处理
    if(gestureRecognizer.numberOfTouches>0){
        return NO;
    }
    
    _panOrigin = vc.view.frame.origin;
    gestureRecognizer.enabled = YES;
    return !_animationInProgress;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    //    if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
    //        UIScrollView * scrollView = (UIScrollView *)otherGestureRecognizer.view;
    //        if (scrollView.contentOffset.x == 0) {
    //            return YES;
    //        }
    //    }
    return NO;
}

#pragma mark - Handle Panning Activity
//处理 pan手势
- (void) gestureRecognizerDidPan:(UIPanGestureRecognizer*)panGesture {
    if(_animationInProgress) return;
    
    
    CGPoint currentPoint = [panGesture translationInView:self.view];
    CGFloat x = currentPoint.x + _panOrigin.x;
    
    PanDirection panDirection = PanDirectionNone;
    CGPoint vel = [panGesture velocityInView:self.view];
    
    if (vel.x > 0) {
        panDirection = PanDirectionRight;
    } else {
        panDirection = PanDirectionLeft;
    }
    
    CGFloat offset = 0;
    
    UIViewController * vc ;
    vc = [self currentViewController];
    offset = CGRectGetWidth(vc.view.frame) - x;
    
    _percentageOffsetFromLeft = offset/[self viewBoundsWithOrientation:self.interfaceOrientation].size.width;
    vc.view.frame = [self getSlidingRectWithPercentageOffset:_percentageOffsetFromLeft orientation:self.interfaceOrientation];
    [self transformAtPercentage:_percentageOffsetFromLeft];
    
    if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) {
        // If velocity is greater than 100 the Execute the Completion base on pan direction
        if(fabs(vel.x) > 100) {
            [self completeSlidingAnimationWithDirection:panDirection];
        }else {
            [self completeSlidingAnimationWithOffset:offset];
        }
    }
}

#pragma mark - Set the required transformation based on percentage
- (void) transformAtPercentage:(CGFloat)percentage {
    CGAffineTransform transf = CGAffineTransformIdentity;
    CGFloat newTransformValue =  1 - (percentage*10)/100;
    CGFloat newAlphaValue = percentage* kMaxBlackMaskAlpha;
    [self previousViewController].view.transform = CGAffineTransformScale(transf,newTransformValue,newTransformValue);
    _blackMask.alpha = newAlphaValue;
}

#pragma mark - This will complete the animation base on pan direction
//完成
- (void) completeSlidingAnimationWithDirection:(PanDirection)direction {
    if(direction==PanDirectionRight){
        [self popVC];
    }else {
        [self rollBackViewController];
    }
}

#pragma mark - This will complete the animation base on offset
//
- (void) completeSlidingAnimationWithOffset:(CGFloat)offset{
    
    if(offset<[self viewBoundsWithOrientation:self.interfaceOrientation].size.width/2) {
        [self popVC];
    }else {
        [self rollBackViewController];
    }
}

#pragma mark - Get the origin and size of the visible viewcontrollers(child)
- (CGRect) getSlidingRectWithPercentageOffset:(CGFloat)percentage orientation:(UIInterfaceOrientation)orientation {
    CGRect viewRect = [self viewBoundsWithOrientation:orientation];
    CGRect rectToReturn = CGRectZero;
    rectToReturn.size = viewRect.size;
    rectToReturn.origin = CGPointMake(MAX(0,(1-percentage)*viewRect.size.width), 0.0);
    return rectToReturn;
}

#pragma mark - Get the size of view in the main screen
- (CGRect) viewBoundsWithOrientation:(UIInterfaceOrientation)orientation{
    CGRect bounds = [UIScreen mainScreen].bounds;
    if([[UIApplication sharedApplication]isStatusBarHidden]){
        return bounds;
    } else if(UIInterfaceOrientationIsLandscape(orientation)){
        CGFloat width = bounds.size.width;
        bounds.size.width = bounds.size.height;
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))  {
            bounds.size.height = width - 20;
        }else {
            bounds.size.height = width;
        }
        return bounds;
    }else{
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))  {
            bounds.size.height-=20;
        }
        return bounds;
    }
}






#pragma mark - private


-(void)removeViewWithOutRootVC{
    
    int count = (int)self.viewControllers.count;
    for (int i=1; i<count; i++) {
        UIViewController * vc = [self.viewControllers objectAtIndex:i];
        [vc.view removeFromSuperview];
    }
}







#pragma mark - rotate
//方向旋转方法
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[self.viewControllers lastObject] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [[self.viewControllers lastObject] willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [[self.viewControllers lastObject] didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - status bar
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return [[self.viewControllers lastObject] preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    return [[self.viewControllers lastObject] prefersStatusBarHidden];
}








@end
