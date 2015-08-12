//
//  GVUserDefaults+Hydro.m
//  Hydro
//
//  Created by kevinzhow on 14/12/25.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import "GVUserDefaults+Hydro.h"
#import "VPNStations.h"

@implementation GVUserDefaults (Hydro)

@dynamic email;
@dynamic token;
@dynamic server;
@dynamic ikev2;
@dynamic currentStationDict;

- (NSDictionary *)setupDefaults {
    return @{
             @"server": [[VPNStations sharedInstance].stations.firstObject valueForKey:@"host"]
             };
}

@end
