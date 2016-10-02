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
@property (nonatomic, assign) float lastZoom;
// last markers array saved last time showed markers on map view
@property (nonatomic, strong) NSMutableArray <PIClusteredMeter *> *lastMeters;
@end

@implementation PIMeterCluster

+ (instancetype)sharedCluster {
    
    static PIMeterCluster *sharedCluster = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCluster = [[PIMeterCluster alloc] init];
        sharedCluster.lastMeters = [NSMutableArray array];
    });
    return sharedCluster;
}

- (void)clusterMeters:(NSArray *)meters map:(GMSMapView *)mapView {
    // 0  remove out bounds markers -> we don't want to add meters that are not showing in the current map view
    NSMutableArray *reminingRegluarMeters = [self reminingRegluarMetersAfterRemoveOutOfBoundsMetersWithCurrentMeters:meters map:mapView];
    
    
//    NSLog(@"地图中还包括 %lu 个正常meter和 %lu 集结过的meter", reminingRegluarMeters.count, self.lastMeters.count);
    
    if (!reminingRegluarMeters) {
        return;
    }
    
//    self.lastMeters = [self reminingRegluarMetersAfterRemoveOutOfBoundsMetersWithCurrentMeters:self.lastMeters map:mapView];

    // NSLog(@"meter count - %lu", reminingRegluarMeters.count);
    if (![self needClusteringWithMap:mapView]) {
        [self showMeters:reminingRegluarMeters onMap:mapView];
        return;
    }

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
    
    if (!metersCopy.count) {
        [mapView clear];
        [self.lastMeters removeAllObjects];
        return nil;
    }
    
    [toRemove removeAllObjects];
    
    for (PIClusteredMeter *meter in self.lastMeters) {
        if (![bounds containsCoordinate:meter.position]) {
            meter.map = nil;
            [toRemove addObject:meter];
        }
    }
    
    [self.lastMeters removeObjectsInArray:toRemove];
    
    return metersCopy;
}

- (BOOL)needClusteringWithMap:(GMSMapView *)mapView {
//    NSLog(@"Zoom - %.1f", mapView.camera.zoom);
    if (mapView.camera.zoom > 17.7f) {
        return NO;
    }
    return YES;
}

- (void)removeTooCloseMeters:(NSMutableArray *)reminingRegluarMeters onMap:(GMSMapView *)mapView {
    // 1 remove meters that are too close to other
    double minDistance = [self minDistanceBetweenEachMeterWithCurrentCameraZoom:mapView.camera.zoom];
    NSMutableArray *toRemove = [NSMutableArray array];
    
    
    // 看看上次的zoom和这次的一样不一样
    if (self.lastZoom != mapView.camera.zoom) {
        
        // 如果不一样的话，首先看图上剩余的clustered meter是不是间距过小，是的话把间距的clustered meter中包含的正常meter数组给另外一个，再把这个clustered meter去除
        for (PIClusteredMeter *meter00 in self.lastMeters) {
            if (![toRemove containsObject:meter00]) {
                //                NSMutableArray <PIMeter *> *containedMeters = [NSMutableArray array];
                for (PIClusteredMeter *meter11 in self.lastMeters) {
                    if (![meter00 isEqual:meter11] && ![toRemove containsObject:meter11]) {
                        CLLocation *location00 = [[CLLocation alloc] initWithLatitude:meter00.position.latitude longitude:meter00.position.longitude];
                        CLLocation *location11 = [[CLLocation alloc] initWithLatitude:meter11.position.latitude longitude:meter11.position.longitude];
                        CLLocationDistance distance = [location00 distanceFromLocation:location11];
                        if (distance < minDistance) {
                            [toRemove addObject:meter11];
                            meter11.map = nil;
                            [meter00.containedMeters addObjectsFromArray:meter11.containedMeters];
                        }
                    }
                }
            }
        }

        
        [self.lastMeters removeObjectsInArray:toRemove];
        [toRemove removeAllObjects];
        self.lastZoom = mapView.camera.zoom;
    }
    
    
    
    

    
    // 新的
    // 首先看地图上还剩下多少clustered meter，把clustered meter包含的正常meter数组清空，再用每一个clustered meter计算出有多少相邻的正常meter，加到数组中
    if (self.lastMeters.count) {
        NSMutableArray <PIMeter *> *usedMeters = [NSMutableArray array];
        for (PIClusteredMeter *clusteredMeter in self.lastMeters) {
            [clusteredMeter.containedMeters removeAllObjects];
            NSMutableArray <PIMeter *> *toAdd = [NSMutableArray array];
            for (PIMeter *meter in reminingRegluarMeters) {
                CLLocation *location00 = [[CLLocation alloc] initWithLatitude:clusteredMeter.position.latitude longitude:clusteredMeter.position.longitude];
                CLLocation *location11 = [[CLLocation alloc] initWithLatitude:meter.position.latitude longitude:meter.position.longitude];
                CLLocationDistance distance = [location00 distanceFromLocation:location11];
                if (distance < minDistance && ![usedMeters containsObject:meter]) {
                    [toAdd addObject:meter];
                    [usedMeters addObject:meter];
                }
            }
            clusteredMeter.containedMeters = toAdd;
        }
        // 加完后，把用过的正常meter从原数组中去除
        [reminingRegluarMeters removeObjectsInArray:usedMeters];
        
        // 看看哪个clustered meter已经不包括任何正常meter，把这个也从数组中去除
        for (PIClusteredMeter *meter in self.lastMeters) {
            if (!meter.containedMeters.count) {
                [toRemove addObject:meter];
                meter.map = nil;
            }
        }
        
        [self.lastMeters removeObjectsInArray:toRemove];
        [toRemove removeAllObjects];
    }
    // 如果图上已经没有正常的meter
    if (!reminingRegluarMeters.count) {
        [self showMeters:nil onMap:mapView];
        return;
    }
    NSLog(@"0 - 地图中还包括 %lu 个正常meter和 %lu 集结过的meter", reminingRegluarMeters.count, self.lastMeters.count);
    // 新的完

    
//    NSMutableArray <PIClusteredMeter *> *thisMeters = [NSMutableArray array];
    
    
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
                
                int i = 0;
                for (PIClusteredMeter *clusteredMeter in self.lastMeters) {
                    if (![self isThisMeter:clusteredMeter smaeLocationWithThatMeter:meter00]) {
                        i ++;
                    } else {
                        clusteredMeter.containedMeters = containedMeters;
                        break;
                    }
                }
                
                
                
                if (i == self.lastMeters.count) {
                    PIClusteredMeter *clusteredMeter = [PIClusteredMeter markerWithPosition:meter00.position];
                    clusteredMeter.containedMeters = containedMeters;
                    [self.lastMeters addObject:clusteredMeter];
//                    [thisMeters addObject:clusteredMeter];
                }
                
//                PIClusteredMeter *clusteredMeter = [PIClusteredMeter markerWithPosition:meter00.position];
//                clusteredMeter.containedMeters = containedMeters;
//                [thisMeters addObject:clusteredMeter];
            } else {
                if (!meter00.map) {
                    meter00.map = mapView;
                }
            }
        }
    }
    
    for (PIMeter *marker in toRemove) {
        marker.map = nil;
    }
    
    NSLog(@"1 - 地图中还包括 %lu 个正常meter和 %lu 集结过的meter", reminingRegluarMeters.count, self.lastMeters.count);
    
    [reminingRegluarMeters removeObjectsInArray:toRemove];
    
    [toRemove removeAllObjects];
    
    /*
    for (PIClusteredMeter *this in thisMeters) {
        for (PIClusteredMeter *last in self.lastMeters) {
            if (this.position.latitude  == last.position.latitude &&
                this.position.longitude == last.position.longitude) {
                this.map = nil;
                [toRemove addObject:this];
//                if (this.containedMeters.count != last.containedMeters.count) {
//                    last.containedMeters = this.containedMeters;
//                }
            }
        }
    }
     */
    
//    for (PIClusteredMeter *last in self.lastMeters) {
////        [reminingRegluarMeters removeObjectsInArray:last.containedMeters];
//        BOOL samePosition = NO;
//        for (PIClusteredMeter *this in thisMeters) {
//            if (this.position.latitude  == last.position.latitude &&
//                this.position.longitude == last.position.longitude) {
//                samePosition = YES;
//            }
//        }
//        
//        if (!samePosition) {
//            last.map = nil;
//            [toRemove addObject:last];
//        }
//    }
//    
//    [thisMeters removeObjectsInArray:toRemove];
//    [self.lastMeters removeObjectsInArray:toRemove];
//    [self.lastMeters addObjectsFromArray:thisMeters];
    
    [self showMeters:reminingRegluarMeters onMap:mapView];
}

- (void)showMeters:(NSMutableArray *)reminingRegluarMeters onMap:(GMSMapView *)mapView {
    NSLog(@"2 - 地图中还包括 %lu 个正常meter和 %lu 集结过的meter", reminingRegluarMeters.count, self.lastMeters.count);
    for (PIMeter *meter in reminingRegluarMeters) {
        if (!meter.map) {
            meter.map = mapView;
        }
    }
    for (PIClusteredMeter *meter in self.lastMeters) {
        for (PIMeter *m in meter.containedMeters) {
            m.map = nil;
        }
        if (!meter.map) {
            meter.map = mapView;
        }
    }
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(id)marker {
    if ([[marker class] isSubclassOfClass:[PIClusteredMeter class]]) {
        GMSMutablePath *path = [GMSMutablePath path];
        PIClusteredMeter *clusteredMeter = (PIClusteredMeter *)marker;
        clusteredMeter.map = nil;
        [self.lastMeters removeObject:clusteredMeter];
        for (PIMeter *PIMeter in clusteredMeter.containedMeters) {
            [path addCoordinate:PIMeter.position];
        }
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
        [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:100.0f]];
        return YES;
    }
    return NO;
}

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

- (BOOL)isThisMeter:(GMSMarker *)this smaeLocationWithThatMeter:(GMSMarker *)that {
    if (this.position.latitude  == that.position.latitude &&
        this.position.longitude == that.position.longitude) {
        return YES;
    }
    return NO;
}

@end
