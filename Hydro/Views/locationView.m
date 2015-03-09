//
//  locationView.m
//  Hydro
//
//  Created by kevinzhow on 14/12/26.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import "locationView.h"
#import <POP.h>

@implementation locationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        int radius = frame.size.width/6;
        int radius_2 = frame.size.width/6.0;
        
        self.circleShape = [CAShapeLayer layer];
        self.circleShape.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                                                         cornerRadius:radius].CGPath;;
        self.circleShape.strokeColor = [[UIColor whiteColor] CGColor];
        self.circleShape.fillColor = [UIColor whiteColor].CGColor;
        self.circleShape.lineWidth = 1.0;
        
        self.circleShape.position = CGPointMake(self.frame.size.width/2.0-radius,
                                                self.frame.size.height/2.0-radius);
        
        self.ringShape = [CAShapeLayer layer];
        self.ringShape.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius_2, 2.0*radius_2)
                                                           cornerRadius:radius_2].CGPath;;
        self.ringShape.strokeColor = [[UIColor whiteColor] CGColor];
        self.ringShape.fillColor = nil;
        self.ringShape.lineWidth = 1.0;

        
        self.ringShape.position = CGPointMake(self.frame.size.width/2.0-radius_2,
                                                self.frame.size.height/2.0-radius_2);
        
        // Add CAShapeLayer to our view
        
        [self.layer addSublayer:self.circleShape];
        [self.layer addSublayer:self.ringShape];
        
        [self waveAnimation];
    }
    
    return self;
}


-(void)waveAnimation
{
    int radius = self.frame.size.width/6;
    int radius_2 = self.frame.size.width/6.0;
    
    POPBasicAnimation *animAlpha = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    animAlpha.fromValue = @1.0;
    animAlpha.toValue = @0.0;
    animAlpha.duration = 3.0;
    animAlpha.completionBlock = ^(POPAnimation *anim, BOOL finished) {

        if (finished) {
            [self waveAnimation];
        }};
    [self.ringShape pop_addAnimation:animAlpha forKey:@"AlphaMap"];
    
    

    CABasicAnimation * pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (id)[UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width/2.0-radius_2, self.frame.size.height/2.0-radius_2, 2.0*radius_2, 2.0*radius_2)
                                                             cornerRadius:radius_2].CGPath;;
    pathAnimation.toValue = (id)[UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width/2.0-radius_2*8, self.frame.size.height/2.0-radius_2*8, 8.0*2*radius_2, 8.0*2*radius_2)
                                                           cornerRadius:radius_2*8].CGPath;;
    pathAnimation.duration = 3.0f;
    pathAnimation.autoreverses = NO;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.ringShape addAnimation:pathAnimation forKey:@"animationKey"];
    
    self.ringShape.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width/2.0-radius_2*8, self.frame.size.height/2.0-radius_2*8, 8.0*2*radius_2, 8.0*2*radius_2)
                                                     cornerRadius:radius_2*8].CGPath;;
    
    
    
    CABasicAnimation * path2Animation = [CABasicAnimation animationWithKeyPath:@"path"];
    path2Animation.fromValue = (id)[UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width/2.0-radius, self.frame.size.height/2.0-radius, 2.0*radius, 2.0*radius)
                                                             cornerRadius:radius].CGPath;;
    path2Animation.toValue = (id)[UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width/2.0-radius, self.frame.size.height/2.0-radius, 2.0*radius, 2.0*radius)
                                                           cornerRadius:radius].CGPath;;
    path2Animation.duration = 3.0f;
    path2Animation.autoreverses = NO;
    path2Animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.circleShape addAnimation:path2Animation forKey:@"animationKey"];
    
    self.circleShape.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.frame.size.width/2.0-radius, self.frame.size.height/2.0-radius, 2.0*radius, 2.0*radius)
                                                       cornerRadius:radius].CGPath;;
}


-(void)show
{
    POPSpringAnimation *animAlpha = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    animAlpha.toValue = @1.0;
    animAlpha.springBounciness = 0.5;
    animAlpha.springSpeed = 12.0;
    animAlpha.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {}};
    [self.layer pop_addAnimation:animAlpha forKey:@"AlphaLocation"];
}

@end
