//
//  VPNStations.h
//  Hydro
//
//  Created by NIX on 14/12/26.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPNStations : NSObject

@property (nonatomic, strong) NSArray *stations;

@property (nonatomic, strong) NSDictionary *config;

+ (VPNStations *)sharedInstance;

@end
