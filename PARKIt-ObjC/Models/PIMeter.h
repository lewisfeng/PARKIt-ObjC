//
//  PIMeter.h
//  PARKIt-ObjC
//
//  Created by YI BIN FENG on 2016-09-18.
//  Copyright © 2016 PARKIt.Vancouver. All rights reserved.
//


@import GoogleMaps;

typedef enum : NSInteger {
    Disability = 100,
    Motorbike  = 101,
    Single     = 102,
    Twin       = 103
} HeadTypes;

@interface PIMeter : GMSMarker

@property (nonatomic, copy) NSString *number;

@property (nonatomic, copy) NSString *timeLimit;
@property (nonatomic, copy) NSString *rate;
@property (nonatomic, copy) NSString *timeEffect;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *rateLevel;
@property (nonatomic, assign) NSInteger headType;

@end
