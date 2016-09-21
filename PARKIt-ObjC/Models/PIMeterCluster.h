//
//  PIMeterCluster.h
//  PARKIt-ObjC
//
//  Created by YI BIN FENG on 2016-09-19.
//  Copyright © 2016 PARKIt.Vancouver. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GMSMapView;

@interface PIMeterCluster : NSObject

+ (instancetype)sharedCluster;

- (void)clusterMeters:(NSArray *)meters map:(GMSMapView *)mapView;
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(id)marker;

@end
