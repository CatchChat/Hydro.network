//
//  scaleView.m
//  Hydro
//
//  Created by kevinzhow on 14/12/25.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import "scaleView.h"
#import <POP.h>

@implementation scaleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.layer pop_removeAnimationForKey:@"AnimationScaleBack"];
    POPSpringAnimation *anim =
    [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    anim.springBounciness = 10;
    anim.springSpeed = 20;
    anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(0.8, 0.8)];
    [self.layer pop_addAnimation:anim forKey:@"AnimationScale"];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.layer pop_removeAnimationForKey:@"AnimationScale"];
    POPSpringAnimation *anim =
    [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    anim.springBounciness = 10;
    anim.springSpeed = 20;
    anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.8, 0.8)];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
    [self.layer pop_addAnimation:anim forKey:@"AnimationScaleBack"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.layer pop_removeAnimationForKey:@"AnimationScale"];
    POPSpringAnimation *anim =
    [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    anim.springBounciness = 10;
    anim.springSpeed = 20;
    anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.8, 0.8)];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
    [self.layer pop_addAnimation:anim forKey:@"AnimationScaleBack"];
    
    
    
}

@end
