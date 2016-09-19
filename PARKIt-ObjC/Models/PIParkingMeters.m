//
//  PIParkingMeters.m
//  PARKIt-ObjC
//
//  Created by YI BIN FENG on 2016-09-18.
//  Copyright © 2016 PARKIt.Vancouver. All rights reserved.
//

#import "PIParkingMeters.h"
#import "PIMeter.h"

#define kPriceFilterLow    @"$0.75-$1.75"
#define kPriceFilterMedium @"$2-$3.75"
#define kPriceFilterHigh   @"$4-up"

NSString * const icon1 = @"GreenBigPark50x50.png";
NSString * const icon2 = @"AmberPark50x50.png";
NSString * const icon3 = @"RedPark50x50.png";
NSString * const icon5 = @"NoParking.png";

@implementation PIParkingMeters

+ (NSMutableArray *)parkingMeters {
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"VancouverParkingMeters" ofType:@"plist"];
    NSMutableArray *parkingMeterDicts = [NSMutableArray arrayWithContentsOfFile:plistPath];
    NSMutableArray *parkingMeters = [NSMutableArray array];

    for (NSDictionary *meterDict in parkingMeterDicts) {
        double lat = [[meterDict objectForKey:@"Latitude" ] doubleValue];
        double lng = [[meterDict objectForKey:@"Longitude"] doubleValue];
        PIMeter *meter = [PIMeter markerWithPosition:CLLocationCoordinate2DMake(lat, lng)];
        meter.number     = [meterDict objectForKey:@"Pay By Phone No."];
        meter.timeLimit  = [meterDict objectForKey:@"Time Limit"];
        meter.timeEffect = [meterDict objectForKey:@"Time in Effect"];
        meter.rate       = [meterDict objectForKey:@"Rate"];

        NSString *meterType = [meterDict objectForKey:@"Meter Head Type:"];
        if ([meterType containsString:@"Disability"]) {
            meter.headType = Disability;
        } else if ([meterType containsString:@"Motorbike"]) {
            meter.headType = Motorbike;
        } else if ([meterType isEqualToString:@"Single"]) {
            meter.headType = Single;
        }  else if ([meterType isEqualToString:@"Twin"]) {
            meter.headType = Twin;
        }
        
        NSString *meterAddress = [meterDict objectForKey:@"Address"];
        NSArray *array = [meterAddress componentsSeparatedByString:@","];
        meter.address = [[array[0] stringByAppendingString:@","] stringByAppendingString:array[1]];

        NSInteger dollarPerHr = [[meter.rate substringWithRange:[meter.rate rangeOfComposedCharacterSequenceAtIndex:1]] integerValue];
        if (dollarPerHr > 4) {
            meter.icon = [UIImage imageNamed:icon3];
            meter.rateLevel = kPriceFilterHigh;
        } else if (dollarPerHr >= 2) {
            meter.icon = [UIImage imageNamed:icon2];
            meter.rateLevel = kPriceFilterMedium;
        } else if (dollarPerHr > 0) {
            meter.icon = [UIImage imageNamed:icon1];
            meter.rateLevel = kPriceFilterLow;
        }
        [parkingMeters addObject:meter];
    }
    return parkingMeters;
}

@end
