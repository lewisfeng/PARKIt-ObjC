//
//  PILocationManager.m
//  PARKIt-ObjC
//
//  Created by YI BIN FENG on 2016-09-18.
//  Copyright © 2016 PARKIt.Vancouver. All rights reserved.
//

#import "PILocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface PILocationManager () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation PILocationManager

+ (instancetype)sharedLocationManager {
    static PILocationManager *sharedLocationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!sharedLocationManager) {
            sharedLocationManager = [[PILocationManager alloc] init];
            sharedLocationManager.locationManager = [[CLLocationManager alloc] init];
            sharedLocationManager.locationManager.delegate = sharedLocationManager;
            sharedLocationManager.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            sharedLocationManager.locationManager.distanceFilter = kCLDistanceFilterNone;

            if ([sharedLocationManager.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                // iOS version 8.0+
                [sharedLocationManager.locationManager requestWhenInUseAuthorization];
            }
        }
    });
    return sharedLocationManager;
}

+ (void)requestWhenInUseAuthorizationCompletion:(void (^)(NSString *, NSString *))completion {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    // The user denied requestWhenInUseAuthorization
    if (status == kCLAuthorizationStatusDenied) {
        NSString *title = @"Location services are off";
        NSString *message = @"To use Location services you must turn on 'While Using the App' in the Location Services Settings";
        completion (title, message);
    }
}

@end
