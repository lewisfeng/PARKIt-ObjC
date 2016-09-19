//
//  PIMeter.h
//  PARKIt-ObjC
//
//  Created by YI BIN FENG on 2016-09-18.
//  Copyright © 2016 PARKIt.Vancouver. All rights reserved.
//


@import GoogleMaps;

typedef enum : NSUInteger {
    Disability = 0,
    Motorbike  = 1
    
} MeterTypes;

@interface PIMeter : GMSMarker

@property (nonatomic, copy) NSString *number;

@property (nonatomic, copy) NSString *timeLimit;
@property (nonatomic, copy) NSString *rate;
@property (nonatomic, copy) NSString *timeEffect;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) NSInteger type;

@end
