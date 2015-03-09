//
//  GVUserDefaults+Hydro.m
//  Hydro
//
//  Created by kevinzhow on 14/12/25.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import "GVUserDefaults+Hydro.h"

@implementation GVUserDefaults (Hydro)

@dynamic email;
@dynamic token;
@dynamic server;
@dynamic currentStationDict;

- (NSDictionary *)setupDefaults {
    return @{
             @"server": @""
             };
}

@end
