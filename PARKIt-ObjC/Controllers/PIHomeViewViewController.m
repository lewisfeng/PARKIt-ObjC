//
//  PIHomeViewViewController.m
//  PARKIt-ObjC
//
//  Created by YI BIN FENG on 2016-09-18.
//  Copyright © 2016 PARKIt.Vancouver. All rights reserved.
//

#import "PIHomeViewViewController.h"
#import "PILocationManager.h"
#import "PIConstants.h"
@import GoogleMaps;

@interface PIHomeViewViewController () <GMSMapViewDelegate>
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSTimer *getUserLocationTimer;
@property (nonatomic, assign) NSInteger getUserLocationFailedCount;
@end

@implementation PIHomeViewViewController

#define kGetUserLocationFailedMaxCount 10

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"PARK-It";
    // location manager
    [PILocationManager sharedLocationManager];
    // add map view
    [self setupMapView];
}

- (void)setupMapView {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:56.0f longitude:-113.0f zoom:2.0f];
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    self.mapView.delegate = self;
    self.mapView.alpha = 0.5f;
    self.mapView.userInteractionEnabled = NO;
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton = YES;
    [self.view addSubview:self.mapView];
    
    self.getUserLocationTimer = [NSTimer scheduledTimerWithTimeInterval:.5f target:self selector:@selector(changeCameraToUserPosition) userInfo:nil repeats:YES];
}

- (void)changeCameraToUserPosition {
    if (!self.mapView.myLocation) {
        self.getUserLocationFailedCount += 1;
        if (self.getUserLocationFailedCount == kGetUserLocationFailedMaxCount) {
            [self.getUserLocationTimer invalidate];
            self.mapView.alpha = 1.0f;
            self.mapView.userInteractionEnabled = YES;
        }
        return;
    }

    double lat = self.mapView.myLocation.coordinate.latitude;
    double lng = self.mapView.myLocation.coordinate.longitude;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:lng zoom:13.9f];
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:1.0f] forKey:kCATransactionAnimationDuration];
    [self.mapView animateToCameraPosition:camera];
    [CATransaction commit];
    [UIView animateWithDuration:kAnimateDuration013f animations:^{
        self.mapView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.mapView.userInteractionEnabled = YES;
    }];
}

#pragma mark GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {

}

@end
