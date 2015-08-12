//
//  GVUserDefaults+Hydro.h
//  Hydro
//
//  Created by kevinzhow on 14/12/25.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import "GVUserDefaults.h"

@interface GVUserDefaults (Hydro)

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *token;

@property (nonatomic) BOOL ikev2;

@property (nonatomic, strong) NSDictionary *currentStationDict;

@end
