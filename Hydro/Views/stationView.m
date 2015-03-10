//
//  stationView.m
//  Hydro
//
//  Created by kevinzhow on 14/12/25.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import "stationView.h"
#import "HydroHelper.h"


@implementation stationView


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        float flagWidth = self.frame.size.width /5;
        self.stationFlag = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2.0 - flagWidth/2.0, 30, flagWidth, self.frame.size.height / 2)];
        [self addSubview:self.stationFlag];
        self.stationFlag.contentMode = UIViewContentModeScaleAspectFit;
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.stationFlag.frame.size.height + 15.0, frame.size.width, 35.0)];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:28.0];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.nameLabel];
        
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.statusLabel.textColor = [UIColor whiteColor];
        self.statusLabel.font = [UIFont fontWithName:@"Avenir" size:16.0];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.statusLabel];
        
        self.stationStatusIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        
        [self addSubview:self.stationStatusIcon];
        
        
        self.shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.statusLabel.bounds];
        [self addSubview:self.shimmeringView];
        
        self.shimmeringView.shimmeringSpeed = 80.0;
        
        self.shimmeringView.contentView = self.statusLabel;
        
        _status = @"Disconnected";


    }
    
    return self;
}


-(void)setName:(NSString *)name
{
    _name = name;
    self.nameLabel.text = name;
}


-(void)setStatus:(NSString *)status
{
    _status = status;
    self.statusLabel.text = status;
    [self.statusLabel sizeToFit];

    self.shimmeringView.frame = self.statusLabel.frame;
    
    if ([status isEqualToString:@"Connected"]) {
        // Start shimmering.
        self.shimmeringView.shimmering = NO;
        self.shimmeringView.center = CGPointMake(SCREEN_WIDTH/2.0 + 5.0, self.nameLabel.center.y + self.nameLabel.frame.size.height / 2 + 15.0);
        self.stationStatusIcon.image = [UIImage imageNamed:@"1"];
    }else{
        // Start shimmering.
        self.shimmeringView.shimmering = YES;
        self.stationStatusIcon.image = nil;
        self.shimmeringView.center = CGPointMake(SCREEN_WIDTH/2.0, self.nameLabel.center.y + self.nameLabel.frame.size.height / 2 + 15.0);
    }
    
    self.stationStatusIcon.center = CGPointMake(self.shimmeringView.center.x - self.shimmeringView.frame.size.width /2.0 - 10.0, self.nameLabel.center.y + self.nameLabel.frame.size.height / 2 + 15.0);
    

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
