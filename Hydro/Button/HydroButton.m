//
//  HydroButton.m
//  Hydro
//
//  Created by kevinzhow on 14/12/25.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import "HydroButton.h"
#import <POP.h>

@implementation HydroButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)touchDown {
    [self.layer pop_removeAnimationForKey:@"AnimationScaleBack"];
    POPSpringAnimation *anim =
    [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    anim.springBounciness = 10;
    anim.springSpeed = 20;
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(0.8, 0.8)];
    [self.layer pop_addAnimation:anim forKey:@"AnimationScale"];
}



- (void)touchUpInside{
    
    [self.layer pop_removeAnimationForKey:@"AnimationScale"];
    POPSpringAnimation *anim =
    [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    anim.springBounciness = 10;
    anim.springSpeed = 20;
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
    [self.layer pop_addAnimation:anim forKey:@"AnimationScaleBack"];
    
    
}


@end
