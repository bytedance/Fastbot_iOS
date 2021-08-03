//MIT License
//
//** ** **
//The fastbot SDK is licensed under the MIT License:
//
//Copyright (c) 2021 Bytedance Inc.
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.


#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "stub.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"
#import "GCDWebServerDataRequest.h"


@interface FastbotStub()

@property(nonatomic, strong) GCDWebServer* webServer;

@end

@implementation FastbotStub

+(void) load{
    // delay listen fastbot
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            [FastbotStub listenFastbot];
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
    });
}


static FastbotStub* __fastbotStub = nil;

+(void) listenFastbot
{
    if(__fastbotStub == nil)
    {
        __fastbotStub = [[FastbotStub alloc] init];
    }
    if(__fastbotStub != nil)
    {
        [__fastbotStub delayListenFastbot];
    }
    
}

-(instancetype)init
{
    self = [super init];
    return self;
}

// describe current App windows
-(NSDictionary*) describePages
{
    NSMutableDictionary* pageDesc = [[NSMutableDictionary alloc] init];
    UIApplication* app = [UIApplication sharedApplication];
    NSArray* windows = nil;
    if (@available(iOS 13.0, *)) {
        NSSet<UIScene *> *scenes = [app connectedScenes];
        for(UIScene* scen in scenes)
        {
            if([scen isKindOfClass:[UIWindowScene class]])
            {
                windows = ((UIWindowScene*)scen).windows;
                break;
            }
        }
    } else {
        windows = [app windows];
    }
    NSMutableArray* pages = [[NSMutableArray alloc] init];
    NSArray<UIWindow*> *sortedWindows = [windows sortedArrayUsingComparator:^NSComparisonResult(UIWindow* w1, UIWindow* w2) {
        if([w1 windowLevel] == [w2 windowLevel])
        {
            if([w1 isKeyWindow]){
                return -1;
            }
            if([w2 isKeyWindow]){
                return 1;
            }
        }
        return [w1 windowLevel] < [w2 windowLevel]? 1 : -1;
    }];
    for(UIView* view in sortedWindows)
    {
        [pages addObject:[self describeUIView:view]];
    }
    pageDesc[@"desc"] = pages;
    return pageDesc;
}

// describe the UIView, prefer more accurate property, prefer more simplify UIView Struct
-(NSDictionary *) describeUIView:(UIView *)view
{
    NSMutableDictionary *viewDesc = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* viewProp = [NSMutableDictionary dictionaryWithDictionary: @{
        @"rect":             [self rectUIView:view],
        @"type":             NSStringFromClass([view class]),
        @"identifier":       [self nonullNSString:[view accessibilityIdentifier]],
        @"visible":          @([@(!view.hidden && view.alpha>0.01) boolValue]),
        @"interactive":      @(view.userInteractionEnabled),
        @"value":            [self nonullNSString:[view accessibilityValue]],
        @"label":            [self nonullNSString:[view accessibilityLabel]],
        @"scrollable":       @([self uiViewScrollable:view]),
        @"clickable":        @([self uiViewClickable:view])
    }];
    NSString* controller = [self uiViewViewControllerStr:view];
    if( 0 != controller.length)
    {
        viewProp[@"controller"]    = controller;
        viewProp[@"vcInheritance"] = [self uiViewVcInhteritChain:view];
    }
    viewDesc[@"view"] = viewProp;
    NSArray *subviews = view.subviews;
    viewDesc[@"children"] = [[NSMutableArray alloc] init];
    if (subviews.count > 0) {
        for (UIView *view in subviews) {
            [viewDesc[@"children"] addObject:[self describeUIView:view ]];
        }
    }
    return viewDesc;
}

// get the UIView's rect
- (NSDictionary *)rectUIView:(UIView*)view{
    CGRect rect;
    rect = [view convertRect:view.bounds toCoordinateSpace:[UIScreen mainScreen].coordinateSpace];
    return @{
            @"left":@(round(rect.origin.x)),
            @"top":@(round(rect.origin.y)),
            @"width":@(round(rect.size.width)),
            @"height":@(round(rect.size.height)),
    };
}

//  is the UIView scrollable
-(BOOL) uiViewScrollable:(UIView*)view
{
    if([view isKindOfClass:[UIScrollView class]])
    {
        return ((UIScrollView*)view).scrollEnabled;
    }
    return NO;
}

// is the UIView clickable, prefer a better hitTest
-(BOOL) uiViewClickable:(UIView*)view
{
    __block BOOL clickable = NO;
    [view.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj,
                                                          NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:[UITapGestureRecognizer class]])
        {
            clickable = YES;
            if( stop != NULL)
            {
                *stop = YES;
            }
        }
    }];
    if(!clickable)
    {
        CGRect  wrect = view.bounds;
        wrect = [view.window convertRect:wrect toView:view];
        CGPoint centerPoint = CGPointMake(CGRectGetMidX(wrect), CGRectGetMidY(wrect));
        UIView* hitestView = [view.window hitTest:centerPoint withEvent:nil];
        clickable = hitestView && ([hitestView isKindOfClass:[UIControl class]] && [view isDescendantOfView:hitestView]);
        clickable = clickable || (hitestView && [hitestView isDescendantOfView:view]);
    }
    
    return clickable;
}

// ViewController of the UIView
-(NSString*) uiViewViewControllerStr:(UIView*)view
{
    id viewController = [self uiViewViewController: view];
    return viewController? NSStringFromClass([viewController class]) : @"";
}

-(id) uiViewViewController:(UIView*)view {
    id responder = [view nextResponder];
    if ([responder isKindOfClass: [UIViewController class]] &&
        ((UIViewController *)responder).view.window &&
        ((UIViewController *)responder).isViewLoaded ) {
        return responder;
    }
    return nil;
}

// Inherit ViewControllers of the UIView
-(NSArray*) uiViewVcInhteritChain:(UIView*)view
{
    NSMutableArray *vcInheritanceChain = [NSMutableArray array];
    id responder = [self uiViewViewController:view];
    if(responder &&
       [responder isKindOfClass:[UIViewController class]] &&
       ((UIViewController *)responder).view.window &&
       ((UIViewController *)responder).isViewLoaded )
    {
        Class respnderclzz = [responder class];
        while([UIViewController class] != respnderclzz) {
            [vcInheritanceChain addObject:NSStringFromClass(respnderclzz)];
            respnderclzz = [respnderclzz superclass];
        }
    }
    return vcInheritanceChain;
}

-(NSString*) nonullNSString:(nullable NSString*) str
{
    return str? str : @"";
}

-(BOOL) delayListenFastbot
{
    if(self.webServer == nil)
    {
        _webServer = [[GCDWebServer alloc] init];
    }
    if(self.webServer.isRunning)
    {
        [self.webServer stop];
    }
    __weak typeof(self) weakSelf = self;
    [self.webServer addHandlerForMethod:@"POST" path:@"/view" requestClass:[GCDWebServerDataRequest class]
                      asyncProcessBlock:^(__kindof GCDWebServerRequest * _Nonnull request, GCDWebServerCompletionBlock  _Nonnull completionBlock) {
        GCDWebServerDataRequest *datarequest = (GCDWebServerDataRequest *)request;
        NSDictionary* data = datarequest.jsonObject;
        NSLog(@"receive request path = %@, %@, %@", request.URL, request.path, request.contentType);
        NSLog(@"request body data %@", data);
        __block GCDWebServerDataResponse* response = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* viewDict = [[NSMutableDictionary alloc] init];
            @try {
               viewDict = [weakSelf describePages];
            }
            @catch(NSException *exception)
            {
               NSLog(@"Describe page Erorr!!! %@", exception.description);
            }
            response = [GCDWebServerDataResponse responseWithJSONObject:viewDict];
            completionBlock(response);
        });
    }];
    
    NSTimeInterval delay = 2.0;
    dispatch_queue_t lfqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(delayTime, lfqueue, ^(void){
        NSDictionary* startEnv = [[NSProcessInfo processInfo] environment];
        NSString* stubPortStr = [startEnv objectForKey:@"stubPort"];
#ifdef DEBUG
        if(stubPortStr == nil)
            stubPortStr = @"9797";
#endif
        if(stubPortStr != nil && stubPortStr.length > 0)
        {
            NSInteger stubPort = [stubPortStr integerValue];
            if(stubPort > 0)
            {
                NSMutableDictionary* options = [NSMutableDictionary dictionary];
                [options setObject:[NSNumber numberWithInteger:stubPort] forKey:GCDWebServerOption_Port];
                [options setObject:@(NO) forKey:GCDWebServerOption_AutomaticallySuspendInBackground];
                NSError* err = nil;
                [weakSelf.webServer  startWithOptions:options error:&err];
                if(err == nil)
                {
                    NSLog(@"start fastbot listen success!");
                }
            }
        }
    });
    return TRUE;
}

@end
