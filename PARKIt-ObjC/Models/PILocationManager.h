//
//  PILocationManager.h
//  PARKIt-ObjC
//
//  Created by YI BIN FENG on 2016-09-18.
//  Copyright © 2016 PARKIt.Vancouver. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PILocationManager : NSObject 
+ (instancetype)sharedLocationManager;
+ (void)requestWhenInUseAuthorizationCompletion:(void (^)(NSString *title, NSString *message))completion;
@end
