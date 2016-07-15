

#import "UIViewController+WXSTransition.h"
#import <objc/runtime.h>

static NSString *AnimationTypeKey = @"animationTypeKey";
static NSString *TargetViewKey = @"TargetViewKey";
static NSString *startViewKey = @"startViewKey";
static NSString *CallBackTransitionKey = @"CallBackTransitionKey";
static NSString *FromVCInteraciveTransitionKey = @"fromVCInteraciveTransitionKey";
static NSString *ToVCInteraciveTransitionKey = @"ToVCInteraciveTransitionKey";
static NSString *wxs_DelegateFlagKey = @"wxs_DelegateFlagKey";

UINavigationControllerOperation _operation;
WXSPercentDrivenInteractiveTransition *_interactive;
WXSTransitionManager *_transtion;

@implementation UIViewController (WXSTransition)


#pragma mark Hook

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method method0 = class_getInstanceMethod(self.class, @selector(wxs_dismissViewControllerAnimated:completion:));
        Method method1 = class_getInstanceMethod(self.class, @selector(dismissViewControllerAnimated:completion:));
        method_exchangeImplementations(method0, method1);
    });
}

#pragma mark Action Method

//Default
- (void)wxs_presentViewController:(UIViewController *)viewControllerToPresent completion:(void (^)(void))completion{

    [self wxs_presentViewController:viewControllerToPresent makeTransition:nil completion:completion];
}

//Choose animation type
-(void)wxs_presentViewController:(UIViewController *)viewControllerToPresent animationType:(WXSTransitionAnimationType )animationType completion:(void (^)(void))completion{
    
    [self wxs_presentViewController:viewControllerToPresent makeTransition:^(WXSTransitionProperty *transition) {
        transition.animationType = animationType;
    } completion:completion];
    
    
}

//make transition
-(void)wxs_presentViewController:(UIViewController *)viewControllerToPresent makeTransition:(WXSTransitionBlock)transitionBlock{
    
    [self wxs_presentViewController:viewControllerToPresent makeTransition:transitionBlock completion:nil];
    
}

//make transition With Completion
-(void)wxs_presentViewController:(UIViewController *)viewControllerToPresent makeTransition:(WXSTransitionBlock)transitionBlock completion:(void (^)(void))completion{
    
    viewControllerToPresent.transitioningDelegate = viewControllerToPresent;
    viewControllerToPresent.animationType = WXSTransitionAnimationTypeDefault;
    viewControllerToPresent.callBackTransition = transitionBlock ? transitionBlock : nil;
    [self presentViewController:viewControllerToPresent animated:YES completion:completion];
    
}

- (void)wxs_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if (self.wxs_DelegateFlag) {
        self.transitioningDelegate = self;
    }
    [self wxs_dismissViewControllerAnimated:flag completion:completion];
}

#pragma mark Property

//----- AnimationType
-(void)setAnimationType:(WXSTransitionAnimationType )animationType {
    objc_setAssociatedObject(self, &AnimationTypeKey, @(animationType), OBJC_ASSOCIATION_ASSIGN);
}
-(WXSTransitionAnimationType)animationType {
    NSInteger type = [objc_getAssociatedObject(self, &AnimationTypeKey) integerValue];
    return (WXSTransitionAnimationType)type;
}

//----- targtView
-(void)setTargetView:(UIView *)targetView {
    objc_setAssociatedObject(self, &TargetViewKey, targetView, OBJC_ASSOCIATION_RETAIN);
}
-(UIView *)targetView{
    return objc_getAssociatedObject(self, &TargetViewKey);
}
//----- startView
-(void)setStartView:(UIView *)startView {
    objc_setAssociatedObject(self, &startViewKey, startView, OBJC_ASSOCIATION_RETAIN);
}
-(UIView *)startView {
    return objc_getAssociatedObject(self, &startViewKey);
}

//----- CallBackTransition
-(void)setCallBackTransition:(WXSTransitionBlock)callBackTransition {
    objc_setAssociatedObject(self, &CallBackTransitionKey, callBackTransition, OBJC_ASSOCIATION_COPY);
}
-(WXSTransitionBlock)callBackTransition{
    return objc_getAssociatedObject(self, &CallBackTransitionKey);
}

//----- wxs_DelegateFlag
-(void)setWxs_DelegateFlag:(BOOL)wxs_DelegateFlag {
    objc_setAssociatedObject(self, &wxs_DelegateFlagKey, @(wxs_DelegateFlag), OBJC_ASSOCIATION_ASSIGN);
}
-(BOOL)wxs_DelegateFlag {
    return [objc_getAssociatedObject(self, &wxs_DelegateFlagKey) integerValue] == 0 ?  NO : YES;
}



#pragma mark Delegate
// ********************** Present Dismiss **********************
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    !_transtion ? _transtion = [[WXSTransitionManager alloc] init] : nil ;
    _transtion.animationType = [self animationType];
    WXSTransitionProperty *make = [[WXSTransitionProperty alloc] init];
    self.callBackTransition ? self.callBackTransition(make) : nil;
    _transtion = [WXSTransitionManager copyPropertyFromObjcet:make toObjcet:_transtion];
    _transtion.transitionType = WXSTransitionTypeDismiss;
    
    
    return _transtion;
    
}
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    !_transtion ? _transtion = [[WXSTransitionManager alloc] init] : nil ;
    _transtion.animationType = [self animationType];
    WXSTransitionProperty *make = [[WXSTransitionProperty alloc] init];
    self.callBackTransition ? self.callBackTransition(make) : nil;
    _transtion = [WXSTransitionManager copyPropertyFromObjcet:make toObjcet:_transtion];
    _transtion.transitionType = WXSTransitionTypePresent;
    self.wxs_DelegateFlag = _transtion.isSysBackAnimation ? NO : YES;
    return _transtion;
    
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator{
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
    return _interactive.isInteractive ? _interactive : nil ;
}


//  ********************** Push Pop **********************

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    
    !_transtion ? _transtion = [[WXSTransitionManager alloc] init] : nil ;
    _transtion.animationType = [self animationType];
    WXSTransitionProperty *make = [[WXSTransitionProperty alloc] init];
    self.callBackTransition ? self.callBackTransition(make) : nil;
    _transtion = [WXSTransitionManager copyPropertyFromObjcet:make toObjcet:_transtion];
    _operation = operation;

    if ( operation == UINavigationControllerOperationPush ) {
        self.wxs_DelegateFlag = _transtion.isSysBackAnimation ? NO : YES;
        _transtion.transitionType = WXSTransitionTypePush;
    }else{
        _transtion.transitionType = WXSTransitionTypePop;
    }

    
    if (_operation == UINavigationControllerOperationPush && _transtion.isSysBackAnimation == NO && _transtion.backGestureEnable) {
        //add gestrue for pop
        !_interactive ? _interactive = [[WXSPercentDrivenInteractiveTransition alloc] init] : nil;
        [_interactive addGestureToViewController:self];
        _interactive.transitionType = WXSTransitionTypePop;
        _interactive.getstureType = _transtion.backGestureType != WXSGestureTypeNone ? _transtion.backGestureType : WXSGestureTypePanRight;
        _interactive.willEndInteractiveBlock = ^(BOOL suceess) {
            _transtion.willEndInteractiveBlock ? _transtion.willEndInteractiveBlock(suceess) : nil;
        };
        
    }
    return _transtion;
    
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    
    !_interactive ? _interactive = [[WXSPercentDrivenInteractiveTransition alloc] init] : nil;
            
    if (_operation == UINavigationControllerOperationPush) {
        return nil;
    }else{
        return _interactive.isInteractive ? _interactive : nil ;
    }
    
}


@end
