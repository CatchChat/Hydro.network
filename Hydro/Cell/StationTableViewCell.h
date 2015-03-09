//
//  StationTableViewCell.h
//  Hydro
//
//  Created by kevinzhow on 14/12/25.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GBPing/GBPing.h>


@interface StationTableViewCell : UITableViewCell<GBPingDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *statusIcon;

@property (nonatomic) NSString * domain;

@property (weak, nonatomic) IBOutlet UIImageView *flagImageView;

@property (weak, nonatomic) IBOutlet UILabel *stationNameLabel;

@property (nonatomic) BOOL isPing;

@property (nonatomic) int stopPingCount;

@property (nonatomic) NSMutableArray * allPingResult;

@property (nonatomic) GBPing * ping;

@property (nonatomic) float rtt;

@property (weak, nonatomic) IBOutlet UIImageView *checkStatusIcon;

@property (nonatomic) NSDictionary * stationDic;

-(void)makeCheck;

@property (nonatomic) BOOL checked;

-(void)setDomain:(NSString *)domain withIndex:(NSInteger)index;
@property (nonatomic) NSInteger failCount;


@end
