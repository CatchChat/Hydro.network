//
//  TodayViewController.m
//  Today
//
//  Created by NIX on 14/12/26.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "VPNStations.h"
#import "VCIPsecVPNManager.h"
#import "VPNButton.h"
#import "HydroHelper.h"
#import <Crashlytics/Crashlytics.h>

@interface TodayViewController () <NCWidgetProviding>

@property (strong, nonatomic) IBOutletCollection(VPNButton) NSArray *vpnButtons;

@property (nonatomic, strong) VPNButton *currentButton;

@property (nonatomic, strong) NSArray *vpnStations;

@property (nonatomic, strong) VCIPsecVPNManager *vpnManager;

@property (nonatomic) BOOL isPrepareProfile;

@end

@implementation TodayViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    self.preferredContentSize = CGSizeMake(0, 80);

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDefaultsDidChange:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)userDefaultsDidChange:(NSNotification *)notification {

#ifdef DEBUG
    NSLog(@"Active Today");
#endif
    [self checkStatus];
}

-(void)checkStatus
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.catchlab.TodayExtensionSharingDefaults"];
    BOOL active = [defaults boolForKey:@"ActiveToday"];
    
    if (active) {
        self.country1.hidden = NO;
        self.country2.hidden = NO;
        self.country3.hidden = NO;
        self.country4.hidden = NO;
        self.signInLabel.alpha = 0;
    }else{
        self.country1.hidden = YES;
        self.country2.hidden = YES;
        self.country3.hidden = YES;
        self.country4.hidden = YES;
        self.signInLabel.alpha = 1;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [Crashlytics startWithAPIKey:@"de004490005a062fa95a4d5676a7edbfbe42c582"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUI) name:NEVPNStatusDidChangeNotification object:nil];
    [self checkStatus];
    
    if (SCREEN_WIDTH <= 320) {

#ifdef DEBUG
        NSLog(@"Relayout");
#endif
        self.country2SpaceConstraint.constant = 7.0;
        self.country3SpaceConstraint.constant = 7.0;
        self.countrySpaceConstraint.constant = 7.0;
        
        [self.view layoutIfNeeded];
        
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray *)vpnStations
{
    if (!_vpnStations) {
        _vpnStations = [VPNStations sharedInstance].stations;
    }
    return _vpnStations;
}

- (VCIPsecVPNManager *)vpnManager
{
    if (!_vpnManager) {
        _vpnManager = [[VCIPsecVPNManager alloc] init];
    }
    return _vpnManager;
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.

    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNoData);
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsMake(0, defaultMarginInsets.left, 0, 0);
}

- (void)viewDidLayoutSubviews
{
#ifdef DEBUG
    NSLog(@"bounds %@", NSStringFromCGRect(self.view.bounds));
#endif
    
    [self.vpnButtons enumerateObjectsUsingBlock:^(VPNButton *button, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectInset(button.bounds, 13, 13)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageNamed:[self.vpnStations[idx] valueForKey:@"short_name"]];
        [button addSubview:imageView];
    }];

    [self.vpnManager prepareWithCompletion:^(NSError *error) {
        if (self.vpnManager.vpnManager.connection.status == NEVPNStatusConnected) {

            NSString *host= self.vpnManager.vpnManager.protocol.serverAddress;

            for (NSInteger i = 0; i < self.vpnStations.count; i++) {
                NSDictionary *station = self.vpnStations[i];
                if ([station[@"host"] isEqualToString:host]) {
                    self.currentButton = self.vpnButtons[i];
                    
                    self.currentButton.buttonState = VPNButtonStateConnected;

                    break;
                }
            }
        }
    }];
}

- (void)refreshUI
{

#ifdef DEBUG
    NSLog(@"refreshUI");
#endif

    [self.vpnManager prepareWithCompletion:^(NSError *error) {

            switch (self.vpnManager.vpnManager.connection.status) {
                case NEVPNStatusConnecting:
                    NSLog(@"NEVPNStatusConnecting");
                    self.currentButton.buttonState = VPNButtonStateConnecting;
                    break;

                case NEVPNStatusConnected:
                    NSLog(@"NEVPNStatusConnected");
                    self.currentButton.buttonState = VPNButtonStateConnected;
                    break;

                case NEVPNStatusDisconnecting:
                    NSLog(@"NEVPNStatusDisconnecting");
                    self.currentButton.buttonState = VPNButtonStateConnecting;
                    break;

                case NEVPNStatusDisconnected:
                    NSLog(@"NEVPNStatusDisconnected");
                    self.currentButton.buttonState = VPNButtonStateNormal;
                    break;
                    
                case NEVPNStatusReasserting:
                    NSLog(@"NEVPNStatusReasserting");
                    self.currentButton.buttonState = VPNButtonStateConnecting;
                    break;
                    
                case NEVPNStatusInvalid:
                    NSLog(@"NEVPNStatusReasserting");
                    self.currentButton.buttonState = VPNButtonStateConnectFailed;
                    
                default:
                    self.currentButton.buttonState = VPNButtonStateNormal;
                    break;
            }

    }];
}

- (IBAction)pressedVPNButton:(VPNButton *)sender {

#ifdef DEBUG
    NSLog(@"pressedVPNButton");
#endif

    BOOL isNewButton = NO;

    if (sender != self.currentButton) {
        isNewButton = YES;

        [self.vpnButtons enumerateObjectsUsingBlock:^(VPNButton *button, NSUInteger idx, BOOL *stop) {
            if (button != sender) {
                button.buttonState = VPNButtonStateNormal;
            }
        }];
    }

    self.currentButton = sender;

    NSInteger indexOfButton = [self.vpnButtons indexOfObject:self.currentButton];

    NSDictionary *station = self.vpnStations[indexOfButton % self.vpnStations.count];
    
    if (self.isPrepareProfile) {
        return;
    }
    self.isPrepareProfile = YES;
    
    [self.vpnManager prepareWithCompletion:^(NSError *error) {
        self.isPrepareProfile = NO;
        
        if (error) {
            self.currentButton.buttonState = VPNButtonStateConnectFailed;
        }else {
            
            if (self.vpnManager.vpnManager.connection.status == NEVPNStatusConnected || self.vpnManager.vpnManager.connection.status == NEVPNStatusConnecting || self.vpnManager.vpnManager.connection.status == NEVPNStatusReasserting || self.vpnManager.vpnManager.connection.status == NEVPNStatusDisconnecting) {
                
#ifdef DEBUG
                NSLog(@"Dicsonnect VPN");
#endif
                
                [self.vpnManager.vpnManager.connection stopVPNTunnel];
                
            } else {
                
#ifdef DEBUG
                NSLog(@"Connect VPN");
#endif
                
                [self connectVPNWithStation:station];
            }
        }
        
    }];
}

- (void)connectVPNWithStation:(NSDictionary *)station {
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.catchlab.TodayExtensionSharingDefaults"];
    BOOL active = [defaults boolForKey:@"ikev2"];
    
    if (active) {
        [self.vpnManager connectIPSecIKEv2WithHost:[station valueForKey:@"host"] andUsername:[[VPNStations sharedInstance].config valueForKey:@"username"] andPassword:[[VPNStations sharedInstance].config valueForKey:@"password"] andPSK:[[VPNStations sharedInstance].config valueForKey:@"psk"] andGroupName:[[VPNStations sharedInstance].config valueForKey:@"groupname"]];
    } else {
        [self.vpnManager connectIPSecWithHost:[station valueForKey:@"host"] andUsername:[[VPNStations sharedInstance].config valueForKey:@"username"] andPassword:[[VPNStations sharedInstance].config valueForKey:@"password"] andPSK:[[VPNStations sharedInstance].config valueForKey:@"psk"]  andGroupName:[[VPNStations sharedInstance].config valueForKey:@"groupname"]];
    }

}


@end
