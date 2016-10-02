//
//  PIClusteredMeter.m
//  PARKIt-ObjC
//
//  Created by YI BIN FENG on 2016-09-19.
//  Copyright © 2016 PARKIt.Vancouver. All rights reserved.
//

#import "PIClusteredMeter.h"

@implementation PIClusteredMeter

- (instancetype)initWithPosition:(CLLocationCoordinate2D)position {
    
    if (self = [super init]) {
        self.position = position;
        self.containedMeters = [NSMutableArray array];
        self.appearAnimation = kGMSMarkerAnimationPop;
    }
    return self;
}

+ (instancetype)markerWithPosition:(CLLocationCoordinate2D)position {
    return [[self alloc] initWithPosition:position];
}

- (void)setContainedMeters:(NSMutableArray *)containedMeters {
    _containedMeters = containedMeters;
    self.icon = [self icon];
}

- (void)setMap:(GMSMapView *)map {
    [super setMap:map];
    self.icon = [self icon];
}

- (UIImage *)icon {
    NSInteger number = self.containedMeters.count;
    CGFloat markerIconWH = 30.0f;
    if (number > 10) {
        markerIconWH = 35.0f;
    } else if (number > 20) {
        markerIconWH = 40.0f;
    } else if (number > 30) {
        markerIconWH = 45.0f;
    } else if (number > 50) {
        markerIconWH = 50.0f;
    } else if (number > 75) {
        markerIconWH = 55.0f;
    } else if (number > 100) {
        markerIconWH = 60.0f;
    } // and so on
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, markerIconWH, markerIconWH)];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, markerIconWH, markerIconWH)];
//    [image setImage:[UIImage imageNamed:@"nown_cluster"]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, markerIconWH, markerIconWH)];
    label.layer.cornerRadius = label.frame.size.width / 2;
    label.layer.borderWidth = 1.5f;
    label.backgroundColor = [UIColor redColor];
    label.layer.borderColor = [UIColor whiteColor].CGColor;
    label.clipsToBounds = YES;
    label.text = [NSString stringWithFormat:@"%lu", (long)number];;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
    label.textAlignment = NSTextAlignmentCenter;
    //    label.backgroundColor = [[UIColor appYellow] colorWithAlphaComponent:0.5];
    
    [view addSubview:image];
    [view addSubview:label];
    
    //grab it
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *icon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return icon;
}

@end

