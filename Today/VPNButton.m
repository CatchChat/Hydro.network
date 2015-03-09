//
//  VPNButton.m
//  Hydro
//
//  Created by NIX on 14/12/26.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import "VPNButton.h"
#import "HydroHelper.h"

@interface VPNButton()

@property (nonatomic, strong) CAShapeLayer *maskShapeLayer;
@property (nonatomic, strong) CAShapeLayer *stateShapeLayer;

@end

@implementation VPNButton

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.12];
    
    [self setBackgroundImage:[HydroHelper imageFromColor:[UIColor colorWithWhite:0.0 alpha:0.32]] forState:UIControlStateHighlighted];
}

- (CAShapeLayer *)maskShapeLayer
{
    if (!_maskShapeLayer) {
        _maskShapeLayer = [CAShapeLayer layer];

        self.layer.mask = _maskShapeLayer;
    }

    return _maskShapeLayer;
}

- (CAShapeLayer *)stateShapeLayer
{
    if (!_stateShapeLayer) {
        _stateShapeLayer = [CAShapeLayer layer];
        _stateShapeLayer.lineWidth = 3.0;
        _stateShapeLayer.strokeColor = [UIColor clearColor].CGColor;
        _stateShapeLayer.fillColor = [UIColor clearColor].CGColor;
        _stateShapeLayer.lineJoin = @"round";
        _stateShapeLayer.lineCap = @"round";

        [self.layer addSublayer:_stateShapeLayer];
    }

    return _stateShapeLayer;
}

- (UIBezierPath *)polygonPathWithRect:(CGRect)rect slides:(NSInteger)slides rotationAngle:(CGFloat)rotationAngle scale:(CGFloat)scale;
{
    CGFloat radius = MIN(rect.size.width, rect.size.height) * 0.5 * scale;
    CGFloat stepAngle = M_PI * 2.0 / slides;
    CGPoint center = CGPointMake(rect.size.width * 0.5, rect.size.height * 0.5);

    UIBezierPath *path  = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(center.x + radius * cosf(0 + stepAngle * 0.5), center.y + radius * sinf(0 + stepAngle * 0.5))];

    for (NSInteger i = 1; i < 6; i++) {
        CGFloat angle = stepAngle * (i);
        [path addLineToPoint:CGPointMake(center.x + radius * cosf(angle + stepAngle * 0.5), center.y + radius * sinf(angle + stepAngle * 0.5))];
    }

    [path closePath];

    return path;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    UIBezierPath *maskPath = [self polygonPathWithRect:self.bounds slides:6 rotationAngle:M_PI / 6.0 scale:1.0];
    self.maskShapeLayer.path = maskPath.CGPath;

    UIBezierPath *statePath = [self polygonPathWithRect:self.bounds slides:6 rotationAngle:M_PI / 6.0 scale:0.9];
    self.stateShapeLayer.path = statePath.CGPath;
}

- (void)setButtonState:(VPNButtonState)buttonState
{
    _buttonState = buttonState;

    NSArray *colors = @[
                        [UIColor clearColor],
                        [UIColor yellowColor],
                        [UIColor colorWithRed:60/255.0 green:171/255.0 blue:218/255.0 alpha:1.0],
                        [UIColor lightGrayColor],
                        ];

    UIColor *color = colors[_buttonState % colors.count];
    self.stateShapeLayer.strokeColor = color.CGColor;
}

@end
