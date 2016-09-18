//
//  PIRootViewControllerHandler.m
//  PARKIt-ObjC
//
//  Created by YI BIN FENG on 2016-09-18.
//  Copyright © 2016 PARKIt.Vancouver. All rights reserved.
//

#import "PIRootViewControllerHandler.h"

#import "PIHomeViewViewController.h"
#import "PITutorialViewController.h"

@interface PIRootViewControllerHandler ()

@end

@implementation PIRootViewControllerHandler

+ (UIViewController *)rootViewController {
    if ([self isFirstTimeLaunch]) {
        return [[PITutorialViewController alloc] init];
    }
    return [[UINavigationController alloc] initWithRootViewController:[[PIHomeViewViewController alloc] init]];
}

// if this is the first time user open the app, show tutorial view controller first
+ (BOOL)isFirstTimeLaunch {
    NSString *launchCountStr = @"launchCount";
    NSInteger launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:launchCountStr];
    if (!launchCount) {
        [[NSUserDefaults standardUserDefaults] setInteger:launchCount + 1 forKey:launchCountStr];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    return NO;
}

//- (void)handleRootViewControllerChange {
//    UIViewController *rootViewController = [PIRootViewControllerHandler rootViewController];
//    rootViewController.view.alpha = 0.0f;
//    [UIView animateWithDuration:0.2 animations:^{
//        self.window.rootViewController.view.alpha = 0.f;
//    } completion:^(BOOL finished) {
//        self.window.rootViewController = rootViewController;
//        [UIView animateWithDuration:0.2 animations:^{
//            rootViewController.view.alpha = 1.f;
//        }];
//    }];
//}

@end
