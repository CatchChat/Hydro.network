//
//  StationTableViewCell.m
//  Hydro
//
//  Created by kevinzhow on 14/12/25.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import "StationTableViewCell.h"
#import <POP.h>
#import "HydroHelper.h"

@implementation StationTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(filterStationStatus:)
                                                 name:CCNFilterStationStatus
                                               object:nil];
    self.backgroundColor = [UIColor clearColor];
}


-(void)filterStationStatus:(NSNotification *)notification
{
    NSDictionary * dict = notification.object;
    if (![[dict valueForKey:@"host"] isEqualToString:self.domain]) {
        [self uncheck];
    }else{
        if (!self.checked) {
            [self doCheck];
        }
    }
}

-(void)ping:(GBPing *)pinger didReceiveReplyWithSummary:(GBPingSummary *)summary {
    
//    NSLog(@"REPLY %@ >  %@", pinger.host, summary);
    [self checkFinalStatusWith:pinger andSummert:summary];

}

-(void)checkFinalStatusWith:(GBPing *)pinger andSummert:(GBPingSummary *)summary
{
    self.rtt += summary.rtt;
    if(self.stopPingCount < 5){
        self.stopPingCount += 1;
        [self.allPingResult addObject:summary];
        
    }else{
        self.isPing = NO;
        [self.ping stop];
        float status = self.rtt/self.stopPingCount * 1000;
        //        NSLog(@"Result is %.3f", status);
        
        if (status < 150) {
            self.statusIcon.image = [UIImage imageNamed:@"1"];
        }else if (status >= 150 && status < 250){
            self.statusIcon.image = [UIImage imageNamed:@"2"];
        }else{
            self.statusIcon.image = [UIImage imageNamed:@"3"];
        }
        
        [self updateFailedCount];
        
    }
}

-(void)updateFailedCount
{
    if (self.failCount / 5.0 > 0.2) {
        self.statusIcon.image = [UIImage imageNamed:@"3"];
    }
}

-(void)setDomain:(NSString *)domain withIndex:(NSInteger)index
{
    _domain = domain;
    
    
    self.ping = [[GBPing alloc] init];
    self.ping.host = domain;
    self.ping.delegate = self;
    self.ping.timeout = 4;
    self.ping.pingPeriod = 0.3 + (0.1 * index);
    self.stopPingCount = 0;
    self.isPing = YES;
    self.allPingResult = [NSMutableArray new];
    self.failCount = 0;
    
    [self.ping setupWithBlock:^(BOOL success, NSError *error) { //necessary to resolve hostname
        if (success) {
            //start pinging
            [self.ping startPinging];
        }
        else {
            NSLog(@"failed to start");
        }
    }];
    
}

//-(void)ping:(GBPing *)pinger didReceiveUnexpectedReplyWithSummary:(GBPingSummary *)summary {
//    NSLog(@"BREPLY> %@", summary);
//    self.failCount += 1;
//    self.stopPingCount += 1;
//    [self checkFinalStatusWith:pinger andSummert:summary];
//}

//-(void)ping:(GBPing *)pinger didSendPingWithSummary:(GBPingSummary *)summary {
//    NSLog(@"SENT %@ >   %@", pinger.host ,summary);
//}

-(void)ping:(GBPing *)pinger didTimeoutWithSummary:(GBPingSummary *)summary {
    NSLog(@"TIMOUT> %@", summary);
    self.failCount += 1;
    self.stopPingCount += 1;
    [self checkFinalStatusWith:pinger andSummert:summary];
}

-(void)ping:(GBPing *)pinger didFailWithError:(NSError *)error {
    NSLog(@"FAIL>   %@", error);
    self.failCount += 1;
    self.stopPingCount += 1;
    [self updateFailedCount];
}
//
-(void)ping:(GBPing *)pinger didFailToSendPingWithSummary:(GBPingSummary *)summary error:(NSError *)error {
    NSLog(@"FSENT>  %@, %@", summary, error);
    self.failCount += 1;
    self.stopPingCount += 1;
    [self checkFinalStatusWith:pinger andSummert:summary];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    NSLog(@"Selected");
    // Configure the view for the selected state
}



-(void)makeCheck
{
    if (self.checked) {

    }else{
        [self doCheck];
    }
}

-(void)uncheck
{
    self.checked = NO;
    self.checkStatusIcon.image = nil;
}

-(void)doCheck{
    
    self.checked = YES;
    self.checkStatusIcon.image = [UIImage imageNamed:@"Check"];
    [[NSNotificationCenter defaultCenter] postNotificationName:CCNFilterStationStatus object:self.stationDic];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    POPSpringAnimation *anim =
    [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    anim.springBounciness = 10;
    anim.springSpeed = 10;
    anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.9)];
    [self.layer pop_addAnimation:anim forKey:@"AnimationScaleTo"];
    anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            
        }
    };
    
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    POPSpringAnimation *anim =
    [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    anim.springBounciness = 10;
    anim.springSpeed = 10;
    anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.9)];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
    [self.layer pop_addAnimation:anim forKey:@"AnimationScaleBack"];
    anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            
        }
    };
    
    [super touchesEnded:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    POPSpringAnimation *anim =
    [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    anim.springBounciness = 10;
    anim.springSpeed = 10;
    anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.9)];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
    [self.layer pop_addAnimation:anim forKey:@"AnimationScaleBack"];
    anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            
        }
    };
    
    [super touchesCancelled:touches withEvent:event];
}

@end
