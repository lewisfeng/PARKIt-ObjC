//
//  PIHelper.h
//  PARKIt-ObjC
//
//  Created by YI BIN FENG on 2016-09-18.
//  Copyright © 2016 PARKIt.Vancouver. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^Alert)(void);

@interface PIHelper : NSObject

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message controller:(UIViewController *)controller block:(Alert)block;

@end
