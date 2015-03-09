//
//  VPNButton.h
//  Hydro
//
//  Created by NIX on 14/12/26.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, VPNButtonState) {
    VPNButtonStateNormal,
    VPNButtonStateConnecting,
    VPNButtonStateConnected,
    VPNButtonStateConnectFailed,
};

@interface VPNButton : UIButton

@property (nonatomic) VPNButtonState buttonState;

@end
