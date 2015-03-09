//
//  VPNStations.m
//  Hydro
//
//  Created by NIX on 14/12/26.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import "VPNStations.h"

@interface VPNStations()

@end

@implementation VPNStations

+ (VPNStations *)sharedInstance
{
    static VPNStations *_sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[VPNStations alloc] init];
    });

    return _sharedInstance;
}

- (NSArray *)stations
{
    if (!_stations) {
        _stations = @[
                      @{
                          @"name":@"Singapore",
                          @"host":@"domain",
                          @"short_name":@"flag_sg",
                          @"x":@0.55,
                          @"y":@(0.40)
                          },
                      @{
                          @"name":@"HongKong",
                          @"host":@"domain",
                          @"short_name":@"HK",
                          @"x":@0.65,
                          @"y":@(0.20)
                          },
                      @{
                          @"name":@"Japan",
                          @"host":@"domain",
                          @"short_name":@"JP",
                          @"x":@0.73,
                          @"y":@(0.15)
                          },
                      @{
                          @"name":@"United States",
                          @"host":@"domain",
                          @"short_name":@"flag_us",
                          @"x":@(-0.5),
                          @"y":@(0.15)
                          }
                      ];
    }
    
    return _stations;
}

@end
