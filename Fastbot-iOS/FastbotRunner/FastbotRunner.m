
//MIT License
//
//** ** **
//The Fastbot-iOS is licensed under the MIT License:
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


//  FastbotRunner.m
//  
//  Created by fastbot on 2021/6/6.
//

#import <XCTest/XCTest.h>
#import "fastbot_native.h"

@interface FastbotRunner : XCTestCase

@property (nonatomic, assign) BOOL shouldKeepRunning;
@end

@implementation FastbotRunner

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.shouldKeepRunning = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitRunloop) name:@"fastbot-done" object:nil];
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

-(void) testFastbot
{
    NSDictionary* startEnv = [[NSProcessInfo processInfo] environment];
    fastbot *fastbot_native = [[Fastbot_native alloc] init:startEnv];
    [fastbot_native start];
    
    // @notice you can uncomment this for some custom action when system alerts
//    [fastbot_native addUIInterruptionMonitor:^CGRect(NSArray<XCUIElement *> *systemAlerts) {
//        NSArray<XCUIElement*> *buttons = [systemAlerts.firstObject.buttons allElementsBoundByIndex];
//        NSInteger buttonCount = [buttons count];
//        CGRect btnRect = CGRectZero;
//        if(buttonCount<=0)
//            return btnRect;
//        if(buttonCount > 2)
//        {
//            btnRect = [[buttons objectAtIndex:1] frame];
//        }
//        else
//            btnRect = [buttons.lastObject frame];
//        return btnRect;
//    }];
    
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    while (self.shouldKeepRunning && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
}


-(void) testPingNetwork
{
    int count = 180;
    while (count--) {
        NSString *getResponeStr = [netclient get:@{} hostport:-1 hostip:@"http://www.bytedance.com" pathStr:@""];
        if(getResponeStr.length > 10)
        {
            [FBLogger log:@"ping network success"];
            return;
        }
        [FBLogger log:@"By tapping FastbotRunner on the device, the screen of the device would go black for about one minute. During the black screen interval, users should press the home button on the device to go back to the main screen. Wait patiently until the network setting dialog window pops up. Users should allow the pop up request in order to continue."];
        [NSThread sleepForTimeInterval:1.0];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)exitRunloop {
    self.shouldKeepRunning = NO;
}

@end
