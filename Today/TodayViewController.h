//
//  TodayViewController.h
//  Today
//
//  Created by NIX on 14/12/26.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPNButton.h"

@interface TodayViewController : UIViewController

@property (weak, nonatomic) IBOutlet VPNButton *country1;

@property (weak, nonatomic) IBOutlet VPNButton *country2;
@property (weak, nonatomic) IBOutlet VPNButton *country3;
@property (weak, nonatomic) IBOutlet UILabel *signInLabel;
@property (weak, nonatomic) IBOutlet VPNButton *country4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countrySpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *country2SpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *country3SpaceConstraint;

@end
