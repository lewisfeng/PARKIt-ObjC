//
//  PIMeterCluster.m
//  PARKIt-ObjC
//
//  Created by YI BIN FENG on 2016-09-19.
//  Copyright © 2016 PARKIt.Vancouver. All rights reserved.
//

#import "PIMeterCluster.h"
#import "PIMeter.h"
#import "PIClusteredMeter.h"
@import GoogleMaps;

@interface PIMeterCluster ()
@property (nonatomic, strong) NSMutableArray *markers;
// last markers array saved last time showed markers on map view
@property (nonatomic, strong) NSMutableArray <PIClusteredMeter *> *lastMeters;
@end

@implementation PIMeterCluster

+ (instancetype)sharedCluster {
    
    static PIMeterCluster *sharedCluster = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCluster = [[PIMeterCluster alloc] init];
    });
    return sharedCluster;
}

- (void)clusterMeters:(NSArray *)meters map:(GMSMapView *)mapView {
    
    // if is an empity array, remove all markers from map view, remove all markers obj from last markers array
//    if (!markers.count) {
//        [mapView clear];
//        [self.lastMeters removeAllObjects];
//        return;
//    }
    
    // 0  remove out bounds markers -> we don't want to add meters that are not showing in the current map view
    NSMutableArray *reminingRegluarMeters = [self reminingRegluarMetersAfterRemoveOutOfBoundsMetersWithCurrentMeters:meters map:mapView];
    NSLog(@"meter count - %lu", reminingRegluarMeters.count);
    
//    [self showMeters:reminingRegluarMeters onMap:mapView];
//    return;
    
    [self removeTooCloseMeters:reminingRegluarMeters onMap:mapView];
}

- (NSMutableArray *)reminingRegluarMetersAfterRemoveOutOfBoundsMetersWithCurrentMeters:(NSArray *)meters map:(GMSMapView *)mapView {
    NSMutableArray *metersCopy = meters.mutableCopy;
    // get bounds
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithRegion:mapView.projection.visibleRegion];
    NSMutableArray *toRemove = [NSMutableArray array];
    for (PIMeter *meter in metersCopy) {
        if (![bounds containsCoordinate:meter.position]) {
            meter.map = nil;
            [toRemove addObject:meter];
        }
    }
    
    [metersCopy removeObjectsInArray:toRemove];
    
    if (!meters.count) {
        [mapView clear];
        [self.lastMeters removeAllObjects];
        return nil;
    }
    
    [toRemove removeAllObjects];
    
    for (PIMeter *meter in self.lastMeters) {
        if (![bounds containsCoordinate:meter.position]) {
            meter.map = nil;
            [toRemove addObject:meter];
        }
    }
    
    [self.lastMeters removeObjectsInArray:toRemove];
    
    return metersCopy;
}

- (void)removeTooCloseMeters:(NSMutableArray *)reminingRegluarMeters onMap:(GMSMapView *)mapView {
    // 1 remove meters that are too close to other
    double minDistance = [self minDistanceBetweenEachMeterWithCurrentCameraZoom:mapView.camera.zoom];
    
    NSMutableArray <PIClusteredMeter *> *thisMeters = [NSMutableArray array];
    NSMutableArray *toRemove = [NSMutableArray array];
    
    for (PIMeter *meter00 in reminingRegluarMeters) {
        if (![toRemove containsObject:meter00]) {
            NSMutableArray <PIMeter *> *containedMeters = [NSMutableArray array];
            for (PIMeter *meter11 in reminingRegluarMeters) {
                if (![meter00 isEqual:meter11] && ![toRemove containsObject:meter11]) {
                    CLLocation *location00 = [[CLLocation alloc] initWithLatitude:meter00.position.latitude longitude:meter00.position.longitude];
                    CLLocation *location11 = [[CLLocation alloc] initWithLatitude:meter11.position.latitude longitude:meter11.position.longitude];
                    CLLocationDistance distance = [location00 distanceFromLocation:location11];
                    if (distance < minDistance) {
                        [toRemove addObject:meter11];
                        if (![containedMeters containsObject:meter11]) {
                            [containedMeters addObject:meter11];
                        }
                    }
                }
            }
            
            if (containedMeters.count > 0) {
                meter00.map = nil;
                [containedMeters addObject:meter00];
                [toRemove addObject:meter00];
                PIClusteredMeter *clusteredMeter = [PIClusteredMeter markerWithPosition:meter00.position];
                clusteredMeter.containedMeters = containedMeters;
                [thisMeters addObject:clusteredMeter];
            } else {
                if (!meter00.map) {
                    meter00.map = mapView;
                }
            }
        }
    }
    NSLog(@"toRemove - %lu", toRemove.count);
    for (PIMeter *marker in toRemove) {
        marker.map = nil;
    }
    
    [reminingRegluarMeters removeObjectsInArray:toRemove];
    
    if (!self.lastMeters.count) {
        self.lastMeters = thisMeters.mutableCopy;
        for (PIMeter *meter in self.lastMeters) {
            if (!meter.map) {
                meter.map = mapView;
            }
        }
        return;
    }
    
    [toRemove removeAllObjects];
    
    for (PIClusteredMeter *this in thisMeters) {
        for (PIClusteredMeter *last in self.lastMeters) {
            if (this.position.latitude  == last.position.latitude &&
                this.position.longitude == last.position.longitude) {
                this.map = nil;
                [toRemove addObject:this];
                if (this.containedMeters.count != last.containedMeters.count) {
                    last.containedMeters = this.containedMeters;
                }
            }
        }
    }
    
    for (PIClusteredMeter *last in self.lastMeters) {
        [reminingRegluarMeters removeObjectsInArray:last.containedMeters];
        BOOL samePosition = NO;
        for (PIClusteredMeter *this in thisMeters) {
            if (this.position.latitude  == last.position.latitude &&
                this.position.longitude == last.position.longitude) {
                samePosition = YES;
            }
        }
        
        if (!samePosition) {
            last.map = nil;
            [toRemove addObject:last];
        }
    }
    
    [thisMeters removeObjectsInArray:toRemove];
    [self.lastMeters removeObjectsInArray:toRemove];
    [self.lastMeters addObjectsFromArray:thisMeters];
    
    NSLog(@"clustered meter count - %lu\n ", self.lastMeters.count);
    
    // show clustered meter on map
    for (PIClusteredMeter *meter in self.lastMeters) {
        meter.map = mapView;
        NSLog(@"clustered meter contains - %lu", meter.containedMeters.count);
    }
    NSLog(@"remining  meter count - %lu", reminingRegluarMeters.count);
    // show regular meter on map
    for (PIMeter *meter in reminingRegluarMeters) {
        meter.map = mapView;
    }
}

- (void)showMeters:(NSMutableArray *)reminingRegluarMeters onMap:(GMSMapView *)mapView {
    for (PIMeter *meter in reminingRegluarMeters) {
        meter.map = mapView;
    }
}

//- (void)showMeters:OnMap:(GMSMapView *)mapView {
//    
//}


//- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(id)marker {
//    
//    if ([[marker class] isSubclassOfClass:[PIMarkerCluster class]]) {
//        
//        GMSMutablePath *path = [GMSMutablePath path];
//        
//        PIMarkerCluster *clusteredMarker = (PIMarkerCluster *)marker;
//        
//        clusteredMarker.map = nil;
//        
//        [self.lastMeters removeObject:clusteredMarker];
//        
//        for (PIMeter *PIMeter in clusteredMarker.containsMeters) {
//            
//            [path addCoordinate:PIMeter.position];
//        }
//        
//        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
//        
//        [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:100.0f]];
//        
//        return YES;
//    }
//    
//    return NO;
//}

#pragma mark - minDistanceBetweenEachMarkerWithCurrentCameraZoom

- (double)minDistanceBetweenEachMeterWithCurrentCameraZoom:(CGFloat)zoom {
    
    CLLocationDistance minDistance;
    if (zoom <= 3.0) {
        minDistance = 1000000;
    } else if (zoom <= 3.5) {
        minDistance = 800000;
    } else if (zoom <= 4) {
        minDistance = 600000;
    } else if (zoom <= 4.5f) {
        minDistance = 390000;
    } else if (zoom <= 5) {
        minDistance = 250000;
    } else if (zoom <= 6) {
        minDistance = 130000;
    } else if (zoom <= 6.5f) {
        minDistance = 80000;
    } else if (zoom <= 7) {
        minDistance = 60000;
    } else if (zoom <= 7.5f) {
        minDistance = 48000;
    } else if (zoom <= 8) {
        minDistance = 39000;
    } else if (zoom <= 8.5f) {
        minDistance = 28000;
    } else if (zoom <= 9) {
        minDistance = 20000;
    } else if (zoom <= 9.5f) {
        minDistance = 15000;
    } else if (zoom <= 10) {
        minDistance = 10000;
    } else if (zoom <= 10.5f) {
        minDistance = 6000;
    } else if (zoom <= 11.5f) {
        minDistance = 3000;
    } else if (zoom <= 12) {
        minDistance = 2000;
    } else if (zoom <= 12.5f) {
        minDistance = 1600;
    } else if (zoom <= 13) {
        minDistance = 1000;
    } else if (zoom <= 14) {
        minDistance = 500;
    } else if (zoom <= 15) {
        minDistance = 300;
    } else if (zoom <= 16) {
        minDistance = 200;
    } else if (zoom <= 17) {
        minDistance = 100;
    } else if (zoom <= 18) {
        minDistance = 30;
    } else if (zoom <= 19) {
        minDistance = 10;
    } else {
        minDistance = 0.1f;
    }
    return minDistance;
}

@end
