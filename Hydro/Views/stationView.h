//
//  stationView.h
//  Hydro
//
//  Created by kevinzhow on 14/12/25.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBShimmeringView.h"

@interface stationView : UIView

@property (nonatomic) UIImageView * stationFlag;

@property (nonatomic) UIImageView * stationStatusIcon;

@property (nonatomic) UILabel * statusLabel;

@property (nonatomic) UILabel * nameLabel;

@property (nonatomic) NSString * name;

@property (nonatomic) NSString * status;

@property (nonatomic) FBShimmeringView * shimmeringView;

@property (nonatomic) BOOL displayed;

@end
