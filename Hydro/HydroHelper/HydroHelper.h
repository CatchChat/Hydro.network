//
//  HydroHelper.h
//  Hydro
//
//  Created by kevinzhow on 14/12/25.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define SCREEN_HEIGHT   ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)

extern NSString * const CCNFillUserInfo;

extern NSString * const CCNFilterStationStatus;


@interface HydroHelper : NSObject

+ (UIImage *)imageFromColor:(UIColor*)color;

@end
