//
//  PIClusteredMeter.h
//  PARKIt-ObjC
//
//  Created by YI BIN FENG on 2016-09-19.
//  Copyright © 2016 PARKIt.Vancouver. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

@interface PIClusteredMeter : GMSMarker

@property (nonatomic, strong) NSMutableArray *containedMeters;

@end
