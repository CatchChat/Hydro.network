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

- (id)init{
    self = [super init];
    if (self) {
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"json"];
        NSData *JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:nil];
        self.stations = [jsonObject valueForKey:@"stations"];
        self.config = jsonObject;
        
    }
    return self;
}


@end
