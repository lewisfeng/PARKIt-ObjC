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
#import "PIHelper.h"
#import "PIParkingMeters.h"
#import "PIMeter.h"
#import "PIMeterCluster.h"
@import GoogleMaps;

@interface PIHomeViewViewController () <GMSMapViewDelegate>
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSTimer *getUserLocationTimer;
@property (nonatomic, assign) NSInteger getUserLocationFailedCount;
@property (nonatomic, copy) NSArray <PIMeter *> *allParkingMeters;
@end

@implementation PIHomeViewViewController

#define kGetUserLocationFailedMaxCount 5

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"PARK-It";
    // location manager
    [PILocationManager sharedLocationManager];
    // add map view
    [self setupMapView];
    
    self.allParkingMeters = [NSArray arrayWithArray:[PIParkingMeters parkingMeters]];

    double lat = 49.300;
    double lng = -122.782;
    double num = 0.0001;
    PIMeter *m0 = [PIMeter markerWithPosition:CLLocationCoordinate2DMake(lat + num, lng + num)];
    num = num + num;
    PIMeter *m1 = [PIMeter markerWithPosition:CLLocationCoordinate2DMake(lat + num, lng + num)];
    num = num + num;
    PIMeter *m2 = [PIMeter markerWithPosition:CLLocationCoordinate2DMake(lat + num, lng + num)];
    num = num + num;
    PIMeter *m3 = [PIMeter markerWithPosition:CLLocationCoordinate2DMake(lat + num, lng + num)];
    num = num + num;
    PIMeter *m4 = [PIMeter markerWithPosition:CLLocationCoordinate2DMake(lat + num, lng + num)];
    num = num + num;
    PIMeter *m5 = [PIMeter markerWithPosition:CLLocationCoordinate2DMake(lat + num, lng + num)];
    num = num + num;
    self.allParkingMeters = [NSArray arrayWithObjects:m0, m1, m2, m3, m4, m5, nil];
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
        [self.getUserLocationTimer invalidate];
        self.mapView.userInteractionEnabled = YES;
    }];
}

#pragma mark GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {

    
    [[PIMeterCluster sharedCluster] clusterMeters:self.allParkingMeters map:mapView];
    
}

- (BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView {
    [PILocationManager requestWhenInUseAuthorizationCompletion:^(NSString *title, NSString *message) {
        [self showAlertWithTitle:title message:message];
    }];
    return NO;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"CLOSE" style:UIAlertActionStyleCancel handler:NULL]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Location Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:NULL];
        }
    }]];
    [self presentViewController:alert animated:NULL completion:NULL];
}

@end
