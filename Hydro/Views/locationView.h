//
//  locationView.h
//  Hydro
//
//  Created by kevinzhow on 14/12/26.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface locationView : UIView

@property (nonatomic) CAShapeLayer * circleShape;

@property (nonatomic) CAShapeLayer * ringShape;

-(void)show;

@end
