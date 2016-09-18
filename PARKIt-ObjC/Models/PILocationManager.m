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

//- (void)changeCameraToUserPosition {
//    if (!CLLocationCoordinate2DIsValid(self.mapView.myLocation.coordinate)) {
//        _getUserLocationFailedCount += 1;
//        if (_getUserLocationFailedCount == kGetUserLocationFailedMaxCount) {
//            [_getUserLocationTimer invalidate];
//            self.mapView.alpha = 1.0f;
//            self.mapView.userInteractionEnabled = YES;
//        }
//        return;
//    }
//    
//    [_getUserLocationTimer invalidate];
//    
//    double lat = self.mapView.myLocation.coordinate.latitude;
//    double lng = self.mapView.myLocation.coordinate.longitude;
//    
//    //    NSLog(@"lat - %f  :  lng - %f", lat, lng);
//    
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:lng zoom:13.9f];
//    [CATransaction begin];
//    [CATransaction setValue:[NSNumber numberWithFloat:1.0f] forKey:kCATransactionAnimationDuration];
//    [self.mapView animateToCameraPosition:camera];
//    [CATransaction commit];
//    [UIView animateWithDuration:kAnimDurQuick animations:^{
//        self.mapView.alpha = 1.0f;
//    } completion:^(BOOL finished) {
//        self.mapView.userInteractionEnabled = YES;
//    }];
//}

@end
