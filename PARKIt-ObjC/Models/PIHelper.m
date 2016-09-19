//
//  PIHelper.m
//  PARKIt-ObjC
//
//  Created by YI BIN FENG on 2016-09-18.
//  Copyright © 2016 PARKIt.Vancouver. All rights reserved.
//

#import "PIHelper.h"

@implementation PIHelper

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message controller:(UIViewController *)controller block:(Alert)block {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"CLOSE" style:UIAlertActionStyleCancel handler:NULL]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Location Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }]];
    [controller presentViewController:alert animated:NULL completion:NULL];
}

@end
