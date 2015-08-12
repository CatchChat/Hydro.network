//
//  ViewController.m
//  Hydro
//
//  Created by kevinzhow on 14/12/25.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import "ViewController.h"
#import "LoginViewController.h"
#import <POP.h>
#import "StationTableViewCell.h"
#import "GVUserDefaults+Hydro.h"
#import "VPNStations.h"
#import "InviteView.h"
#import <AFNetworking.h>
#import <SVProgressHUD.h>

#define TableViewTopConstraintInitialConstant (-400.0)

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;

@property (nonatomic) NSArray *vpnStations;
@property (nonatomic) NSDictionary *stationDic;

@property (nonatomic, weak) InviteView *inviteView;

@property (nonatomic)  HydroButton *connectButton;
@property (nonatomic)  UIImageView *mapImageVIew;

@property (nonatomic)  UILabel *donaterLabel;

@property (nonatomic) VCIPsecVPNManager * vpnmanager;

@property (nonatomic) NSString * domain;

@property (nonatomic) NSDictionary * currentStationDict;

@property (nonatomic) stationView * stationViewOne;

@property (nonatomic) locationView * stationLocationView;

@property (nonatomic) BOOL userHasLogined;

@property (nonatomic) BOOL userCanInvite;

@property (nonatomic) BOOL stationShowed;

@property (nonatomic) BOOL isPrepareProfile;


- (IBAction)doConnect:(id)sender;

@end

@implementation ViewController

- (NSArray *)vpnStations
{
    if (!_vpnStations) {
        _vpnStations = [VPNStations sharedInstance].stations;
    }
    return _vpnStations;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapImageVIew = [[UIImageView alloc] initWithFrame:CGRectMake(0, -100, SCREEN_WIDTH, 267)];
    self.mapImageVIew.image = [UIImage imageNamed:@"World Map"];
    self.mapImageVIew.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.mapImageVIew];
    
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    headerView.backgroundColor = [UIColor clearColor];
    self.stationLocationView = [[locationView alloc] initWithFrame:CGRectMake(self.mapImageVIew.frame.size.width /2.0 - 15.0, self.mapImageVIew.frame.size.height /2.0 - 15.0, 30.0, 30.0)];
    self.stationLocationView.alpha = 0.0;
    [self.mapImageVIew addSubview:self.stationLocationView];

    
    self.stationViewOne = [[stationView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 210.0)];
    [self.view addSubview:self.stationViewOne];
    self.stationViewOne.alpha = 0;
    
    //self.stationDelegate = [[stationsDelegate alloc] init];
    self.connectButton = [HydroButton buttonWithType:UIButtonTypeCustom];
    [self.connectButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Medium" size:17.0]];
    

    
    self.connectButton.frame = CGRectMake(SCREEN_WIDTH/2.0 - 120 , SCREEN_HEIGHT + 140, 240, 60);
    
    self.donaterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (SCREEN_HEIGHT - 160.0) , SCREEN_WIDTH, 30)];
    self.donaterLabel.alpha = 0;
    self.donaterLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    self.donaterLabel.textAlignment = NSTextAlignmentCenter;
    [self.donaterLabel setFont:[UIFont fontWithName:@"Avenir-Medium" size:14.0]];
    
    [self.view addSubview:self.donaterLabel];
    
    [self.connectButton setBackgroundImage:[UIImage imageNamed:@"Button + Connect"] forState:UIControlStateNormal];
    [self.view addSubview:self.connectButton];
    [self.connectButton addTarget:self action:@selector(doConnect:) forControlEvents:UIControlEventTouchUpInside];
    [self.connectButton addTarget:self.connectButton action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
    [self.connectButton addTarget:self.connectButton action:@selector(touchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.connectButton addTarget:self.connectButton action:@selector(touchUpInside) forControlEvents:UIControlEventTouchDragOutside];
    
    [self.connectButton setTitle:NSLocalizedString(@"Connect", nil) forState:UIControlStateNormal];
    self.connectButton.alpha = 0;

    self.tableViewTopConstraint.constant = TableViewTopConstraintInitialConstant;
    self.stationsTableVIew.tableHeaderView = headerView;
    self.stationsTableVIew.delegate = self;
    self.stationsTableVIew.dataSource = self;
    [self.stationsTableVIew reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(filterStationStatus:)
                                                 name:CCNFilterStationStatus
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fillUserInfo)
                                                 name:CCNFillUserInfo
                                               object:nil];
    
    self.vpnmanager = [[VCIPsecVPNManager alloc] init];
    [self addMotionOnMap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vpnConnectionStatusChanged:) name:NEVPNStatusDidChangeNotification object:nil];
    

    if (![GVUserDefaults standardUserDefaults].token) {
        LoginViewController * loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        loginViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        [self presentViewController:loginViewController animated:NO completion:^{
            
        }];
    }else{
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.catchlab.TodayExtensionSharingDefaults"];
        
        [sharedDefaults setBool:YES forKey:@"ActiveToday"];
        [sharedDefaults synchronize];   // (!!) This is crucial.
        [self checkCanInvite];
        [[NSNotificationCenter defaultCenter] postNotificationName:CCNFillUserInfo object:nil];
        [self validateUser];
    }
    
    [self.view bringSubviewToFront:self.stationsTableVIew];
    [self.view bringSubviewToFront:self.connectButton];
    
    
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        NSLog(@"Change IKEV");
        
        NSString * message = @"Choose The Encrypt Protocal";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Make A Change" message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ikev2 = [UIAlertAction actionWithTitle:@"IKEv2" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [GVUserDefaults standardUserDefaults].ikev2 = YES;
        }];
        
        UIAlertAction* ikev1 = [UIAlertAction actionWithTitle:@"IKEv1" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [GVUserDefaults standardUserDefaults].ikev2 = NO;
        }];
        
        
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.catchlab.TodayExtensionSharingDefaults"];
        
        [sharedDefaults setBool:[GVUserDefaults standardUserDefaults].ikev2 forKey:@"ikev2"];
        [sharedDefaults synchronize];   // (!!) This is crucial.
        
        [alertController addAction:ikev2];
        [alertController addAction:ikev1];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.userHasLogined) {
        [self relayout];
        [self checkCanInvite];
    }

}

-(void)checkCanInvite
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"user_token":[GVUserDefaults standardUserDefaults].token
                                 };
    [manager POST:[NSString stringWithFormat:@"%@%@",[[VPNStations sharedInstance].config valueForKey:@"server"], [[VPNStations sharedInstance].config valueForKey:@"can_do_invite"]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
#ifdef DEBUG
        NSLog(@"JSON: %@", responseObject);
#endif
        
        NSString * status = [responseObject valueForKey:@"status"];
        
        if([status isEqualToString:@"error"]){
            self.userCanInvite = NO;
        }else{
            self.userCanInvite = YES;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
#ifdef DEBUG
        NSLog(@"Error: %@", error);
#endif
        self.userCanInvite = NO;
    }];

    
}

-(void)addMotionOnMap
{
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-20);
    verticalMotionEffect.maximumRelativeValue = @(20);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-20);
    horizontalMotionEffect.maximumRelativeValue = @(20);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [self.mapImageVIew addMotionEffect:group];
}

-(void)vpnConnectionStatusChanged:(NSNotification *)notification
{
    [self relayout];
}

-(void)filterStationStatus:(NSNotification *)notification
{
    NSDictionary * dict = notification.object;
    self.currentStationDict = dict;
    self.domain = [dict valueForKey:@"host"];

    if (![[[GVUserDefaults standardUserDefaults].currentStationDict valueForKey:@"host"] isEqualToString:[dict valueForKey:@"host"]]) {
        [GVUserDefaults standardUserDefaults].server = self.domain;
        [GVUserDefaults standardUserDefaults].currentStationDict = dict;
    }
    
    [self fillWithStationView:self.stationViewOne];
    
    [self changeLocation:CGPointMake([[dict valueForKey:@"x"] floatValue], [[dict valueForKey:@"y"] floatValue])];
    
#ifdef DEBUG
    NSLog(@"Change domian to %@",[GVUserDefaults standardUserDefaults].currentStationDict );
#endif

}


-(void)changeLocation:(CGPoint)point
{

    
#ifdef DEBUG
    NSLog(@"Change station to %f %f",point.x, point.y );
#endif
    
    POPSpringAnimation *animAlpha = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    animAlpha.toValue = @0.0;
    animAlpha.springBounciness = 4.0;
    animAlpha.springSpeed = 12.0;
    animAlpha.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {}};
    [self.stationLocationView.layer pop_addAnimation:animAlpha forKey:@"AlphaMap"];
    
    animAlpha.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            
            self.stationLocationView.center = CGPointMake((self.mapImageVIew.frame.size.width /0.9) /2.0 + ((self.mapImageVIew.frame.size.width /0.9) /2.0 * point.x) - 15.0, (self.mapImageVIew.frame.size.height/0.9) /2.0 + ((self.mapImageVIew.frame.size.height/0.9) /2.0 * point.y) -15.0);
            
            POPSpringAnimation *animAlpha = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
            animAlpha.toValue = @1.0;
            animAlpha.springBounciness = 4.0;
            animAlpha.springSpeed = 12.0;
            animAlpha.completionBlock = ^(POPAnimation *anim, BOOL finished) {
                if (finished) {}};
            [self.stationLocationView.layer pop_addAnimation:animAlpha forKey:@"AlphaMap"];
            
        
            
        }
    };
    
}




- (void)fillUserInfo
{
    self.userHasLogined = YES;
    
#ifdef DEBUG
    NSLog(@"User Do login");
#endif
    self.mapImageVIew.image = [UIImage imageNamed:@"World Map"];
    
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2.0, (SCREEN_HEIGHT - 240.0) )];
    anim.springBounciness = 4.0;
    anim.springSpeed = 12.0;
    anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {}};
    [self.mapImageVIew.layer pop_addAnimation:anim forKey:@"MoveMap"];
    
    POPSpringAnimation *animAlpha = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    animAlpha.toValue = @1.0;
    animAlpha.springBounciness = 4.0;
    animAlpha.springSpeed = 12.0;
    animAlpha.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {}};
    [self.mapImageVIew.layer pop_addAnimation:animAlpha forKey:@"AlphaMap"];
    
    POPSpringAnimation *animSize = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    animSize.toValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.9)];
    animSize.springBounciness = 15.0;
    animSize.springSpeed = 12.0;
    animSize.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            
#ifdef DEBUG
            NSLog(@"Update station %@", [GVUserDefaults standardUserDefaults].currentStationDict);
#endif
            
            if ([GVUserDefaults standardUserDefaults].currentStationDict) {
                self.currentStationDict = [GVUserDefaults standardUserDefaults].currentStationDict;
                [self changeLocation:CGPointMake([[self.currentStationDict valueForKey:@"x"] floatValue], [[self.currentStationDict valueForKey:@"y"] floatValue])];
                [[NSNotificationCenter defaultCenter] postNotificationName:CCNFilterStationStatus object:self.currentStationDict];
            }else{
                [self changeLocation:CGPointMake(0, 0)];
            }

            [self.stationLocationView show];
            
            POPSpringAnimation *animAlpha = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
            animAlpha.toValue = @1.0;
            animAlpha.springBounciness = 4.0;
            animAlpha.springSpeed = 12.0;
            animAlpha.completionBlock = ^(POPAnimation *anim, BOOL finished) {
                if (finished) {}};
            [self.connectButton.layer pop_addAnimation:animAlpha forKey:@"AlphaMap"];
            
            POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
            anim.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2.0, (SCREEN_HEIGHT - 70.0) )];
            anim.springBounciness = 10.0;
            anim.springSpeed = 12.0;
            anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
                if (finished) {
                    
                    [self relayout];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [UIView animateWithDuration:0.3 animations:^{
                            
                            NSString * sponser = [self.stationDic valueForKey:@"sponser"];
                            
                            NSString * name = [self.stationDic valueForKey:@"name"];
                            
                            if (![sponser isEqualToString:@""]) {
                                self.donaterLabel.text = [NSString stringWithFormat:@"%@ sponsored by %@", name, sponser];
                                self.donaterLabel.alpha = 1.0;
                            } else {
                                self.donaterLabel.alpha = 0.0;
                            }
                            
                            
                        }];
                        
                    });
                    
                    
                    
                }
            };
            [self.connectButton.layer pop_addAnimation:anim forKey:@"MoveMap"];
            
            
            [self showStations];
            
        }
    };
    [self.mapImageVIew.layer pop_addAnimation:animSize forKey:@"SizeMap"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doConnect:(id)sender {
    
    
//    [self bumbButton];
    if (self.isPrepareProfile) {
        return;
    }
    self.isPrepareProfile = YES;
    [self.vpnmanager prepareWithCompletion:^(NSError *error) {
        self.isPrepareProfile = NO;

        if (self.vpnmanager.vpnManager.connection.status != NEVPNStatusDisconnected && self.vpnmanager.vpnManager.connection.status != NEVPNStatusInvalid) {
            
            [self.vpnmanager.vpnManager.connection stopVPNTunnel];
            
            [self showStations];
            
            NSLog(@"Show stations");
            
        }else{
            if (self.domain) {
                
                [self hideStations];
                
                
                if ([GVUserDefaults standardUserDefaults].ikev2) {
                    [self.vpnmanager connectIPSecIKEv2WithHost:self.domain andUsername:[[VPNStations sharedInstance].config valueForKey:@"username"] andPassword:[[VPNStations sharedInstance].config valueForKey:@"password"] andPSK:[[VPNStations sharedInstance].config valueForKey:@"psk"] andGroupName:[[VPNStations sharedInstance].config valueForKey:@"groupname"]];
                } else {
                    [self.vpnmanager connectIPSecWithHost:self.domain andUsername:[[VPNStations sharedInstance].config valueForKey:@"username"] andPassword:[[VPNStations sharedInstance].config valueForKey:@"password"] andPSK:[[VPNStations sharedInstance].config valueForKey:@"psk"]  andGroupName:[[VPNStations sharedInstance].config valueForKey:@"groupname"]];
                }

            }
        }
        
    }];


}

-(void)showStationView
{
    [self fillWithStationView:self.stationViewOne];
    
    POPSpringAnimation *animAlpha = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    animAlpha.toValue = @1.0;
    animAlpha.springBounciness = 4.0;
    animAlpha.springSpeed = 12.0;
    animAlpha.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {}};
    [self.stationViewOne.layer pop_addAnimation:animAlpha forKey:@"AlphaMap"];
    
    POPSpringAnimation *anim =
    [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    anim.springBounciness = 10;
    anim.springSpeed = 20;
    anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
    [self.stationViewOne.layer pop_addAnimation:anim forKey:@"AnimationScaleBack"];
    
    self.stationViewOne.displayed = YES;
    
}

-(void)hideStationView
{
    
    POPSpringAnimation *animAlpha = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    animAlpha.toValue = @0.0;
    animAlpha.springBounciness = 4.0;
    animAlpha.springSpeed = 12.0;
    animAlpha.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {}};
    [self.stationViewOne.layer pop_addAnimation:animAlpha forKey:@"AlphaMap"];
    
    POPSpringAnimation *anim =
    [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    anim.springBounciness = 10;
    anim.springSpeed = 20;
    anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)];
    [self.stationViewOne.layer pop_addAnimation:anim forKey:@"AnimationScaleBack"];
    
    self.stationViewOne.displayed = NO;
    
}

- (void)hideTableView
{
    
#ifdef DEBUG
    NSLog(@"Hide table view");
#endif
    [self.tableViewTopConstraint pop_removeAnimationForKey:@"stationsHideAnimation"];
    POPSpringAnimation *stationsHideAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    stationsHideAnimation.toValue = @(TableViewTopConstraintInitialConstant);
    stationsHideAnimation.springSpeed = 4.0;
    stationsHideAnimation.springBounciness = 0.0;
    stationsHideAnimation.removedOnCompletion = YES;
    [self.tableViewTopConstraint pop_addAnimation:stationsHideAnimation forKey:@"stationsHideAnimation"];

        [self.tableViewTopConstraint pop_removeAnimationForKey:@"AlphaMap"];
    POPSpringAnimation *animAlpha = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    animAlpha.toValue = @0.0;
    animAlpha.springBounciness = 0.0;
    animAlpha.springSpeed = 20.0;
    animAlpha.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {}};
    animAlpha.removedOnCompletion = YES;
    [self.stationsTableVIew.layer pop_addAnimation:animAlpha forKey:@"AlphaMap"];
}

-(void)hideStations
{
    [self hideTableView];

    [self showStationView];
    
    self.stationShowed = NO;
}

- (void)showTableView
{
    
    POPSpringAnimation *stationsShowAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    stationsShowAnimation.toValue = @0;
    stationsShowAnimation.springSpeed = 6.0;
    stationsShowAnimation.springBounciness = 10.0;
    stationsShowAnimation.removedOnCompletion = YES;
    [self.tableViewTopConstraint pop_addAnimation:stationsShowAnimation forKey:@"stationsShowAnimation"];

    POPSpringAnimation *animAlpha = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    animAlpha.toValue = @1.0;
    animAlpha.springBounciness = 4.0;
    animAlpha.springSpeed = 12.0;
    animAlpha.removedOnCompletion = YES;
    [self.stationsTableVIew.layer pop_addAnimation:animAlpha forKey:@"AlphaMap"];
}

-(void)showStations
{
    [self showTableView];

    [self hideStationView];
    
    self.stationShowed = YES;
}

-(void)relayout
{
    
    [self.vpnmanager prepareWithCompletion:^(NSError *error) {

            if (self.vpnmanager.vpnManager.connection.status == NEVPNStatusConnected) {

                
                [UIView transitionWithView:self.mapImageVIew
                                  duration:0.3
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    self.mapImageVIew.image = [UIImage imageNamed:@"Map"];
                                }
                                completion:NULL];
                self.stationViewOne.status = @"Connected";
                //                [self activeButtonStatus:self.connectionButton];
                
                [self.connectButton setTitle:NSLocalizedString(@"Disconnect", nil) forState:UIControlStateNormal];
                [self.connectButton setBackgroundImage:[UIImage imageNamed:@"Button_wire"] forState:UIControlStateNormal];
                
                if (!self.stationViewOne.displayed) {
                    [self hideStations];
                }
                
            }else if (self.vpnmanager.vpnManager.connection.status == NEVPNStatusConnecting) {
                
                //                [self activeButtonStatus:self.connectionButton];

                self.stationViewOne.status = @"Connecting";
                [self.connectButton setTitle:NSLocalizedString(@"Connecting", nil) forState:UIControlStateNormal];
                [self.connectButton setBackgroundImage:[UIImage imageNamed:@"Button_wire"] forState:UIControlStateNormal];
                
            }
            else if ( self.vpnmanager.vpnManager.connection.status == NEVPNStatusDisconnecting)
            {

//                [self.connectButton setTitle:@"Disconnection" forState:UIControlStateNormal];
            }
            else if(self.vpnmanager.vpnManager.connection.status == NEVPNStatusDisconnected){

                [UIView transitionWithView:self.mapImageVIew
                                  duration:0.3
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    self.mapImageVIew.image = [UIImage imageNamed:@"World Map"];
                                }
                                completion:NULL];
                
                [self.connectButton setTitle:NSLocalizedString(@"Connect", nil) forState:UIControlStateNormal];
                [self.connectButton setBackgroundImage:[UIImage imageNamed:@"Button + Connect"] forState:UIControlStateNormal];
                if (![self.stationViewOne.status isEqualToString:@"Disconnected"] && !self.stationShowed) {
                    [SVProgressHUD showInfoWithStatus:@"Connect Failed"];
                    [self showStations];
                }

                self.stationViewOne.status = @"Disconnected";
                //                [self inactiveButtonStatus:self.connectionButton];
            }

        
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.vpnStations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"stationCell"];
    if (cell == nil) {
        cell = [[StationTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"stationCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    NSDictionary * station = [self.vpnStations objectAtIndex:indexPath.row];

    cell.flagImageView.image = [UIImage imageNamed:[station valueForKey:@"short_name"]];
    cell.stationNameLabel.text =[station valueForKey:@"name"];
    [cell setDomain:[station valueForKey:@"host"] withIndex:indexPath.row];
    if([cell.domain isEqualToString:[GVUserDefaults standardUserDefaults].server]){
        self.stationDic = [self.vpnStations objectAtIndex:indexPath.row];
    }

    cell.stationDic = station;
    
#ifdef DEBUG
    NSLog(@"Show cell");
#endif

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
#ifdef DEBUG
    NSLog(@"Did select row");
#endif

    StationTableViewCell *cell = (StationTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell makeCheck];

    self.stationDic = [self.vpnStations objectAtIndex:indexPath.row];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        NSString * sponser = [self.stationDic valueForKey:@"sponser"];
        
        NSString * name = [self.stationDic valueForKey:@"name"];
        
        if (![sponser isEqualToString:@""]) {
            self.donaterLabel.text = [NSString stringWithFormat:@"%@ sponsored by %@", name, sponser];
            self.donaterLabel.alpha = 1.0;
        } else {
            self.donaterLabel.alpha = 0.0;
        }
        
        
        
    }];
}


-(void)fillWithStationView:(stationView *)view
{
    view.stationFlag.image = [UIImage imageNamed:[self.stationDic valueForKey:@"short_name"]];
    view.name = [self.stationDic valueForKey:@"name"];
    view.status = @"Connecting";
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
#ifdef DEBUG
    NSLog(@"scrollView.contentOffset.y: %@", @(scrollView.contentOffset.y));
#endif

    [self.stationsTableVIew.layer pop_removeAnimationForKey:@"stationsShowAnimation"];

    CGFloat thresholdForShowInviteView = 70.0;

    if (self.inviteView) {
//        scrollView.alpha = 0.0;
    } else if (self.userCanInvite){
        scrollView.alpha = 1.0 - (MIN(thresholdForShowInviteView, scrollView.contentOffset.y) / thresholdForShowInviteView);
    }

    if (scrollView.contentOffset.y > thresholdForShowInviteView) {
        
        if (!self.inviteView && self.userCanInvite) {
            //scrollView.hidden = YES;
            scrollView.scrollEnabled = NO;
            //CGPoint contentOffset = scrollView.contentOffset;
            //contentOffset.y = thresholdForShowInviteView;
            //scrollView.contentOffset = contentOffset;
            scrollView.alpha = 0.0;
            //scrollView.hidden = NO;
            //NSLog(@"do show invite view");
            [self showInviteView];
        }
    }
}

#pragma mark - Invite View

- (InviteView *)makeInviteView
{
    InviteView *inviteView = [[InviteView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    //inviteView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];

    [self.view addSubview:inviteView];

    return inviteView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self invite];
    
    return YES;
}

- (void)invite
{

#ifdef DEBUG
    NSLog(@"do invite");
#endif
    if (!self.inviteView.emailTextField.text.length > 1) {
        return;
    }
    
    [SVProgressHUD show];
    [self doInviteEmail:self.inviteView.emailTextField.text];
    [self hideInviteView];
}

- (void)showInviteView
{
    self.inviteView = [self makeInviteView];

    [self hideTableView];

    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH * 0.5, (SCREEN_WIDTH * 0.3))];
    anim.springBounciness = 4.0;
    anim.springSpeed = 12.0;
    anim.removedOnCompletion = YES;
    [self.mapImageVIew.layer pop_addAnimation:anim forKey:@"MoveMap"];

    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.2, 1.2)];
    scaleAnimation.removedOnCompletion = YES;
    [self.mapImageVIew.layer pop_addAnimation:scaleAnimation forKey:@"Scale"];


    POPSpringAnimation *showInviteViewAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    showInviteViewAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH * 0.5, (SCREEN_HEIGHT * 0.5))];
    showInviteViewAnimation.springBounciness = 4.0;
    showInviteViewAnimation.springSpeed = 12.0;
    showInviteViewAnimation.removedOnCompletion = YES;
    showInviteViewAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            [_inviteView.emailTextField becomeFirstResponder];
            _inviteView.emailTextField.delegate = self;

            [_inviteView.inviteButton addTarget:self action:@selector(invite) forControlEvents:UIControlEventTouchUpInside];
            
            UISwipeGestureRecognizer *swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideInviteView)];
            swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
            [_inviteView addGestureRecognizer:swipeDownGestureRecognizer];
        }
    };

    [_inviteView.layer pop_addAnimation:showInviteViewAnimation forKey:@"showInviteViewAnimation"];
}

- (void)hideInviteView
{
    [self.inviteView.emailTextField resignFirstResponder];

    self.stationsTableVIew.scrollEnabled = YES;

    POPSpringAnimation *hideInviteViewAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    hideInviteViewAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH * 0.5, (SCREEN_HEIGHT * 1.5))];
    hideInviteViewAnimation.springBounciness = 4.0;
    hideInviteViewAnimation.springSpeed = 8.0;
    hideInviteViewAnimation.removedOnCompletion = YES;

    [_inviteView.layer pop_addAnimation:hideInviteViewAnimation forKey:@"hideInviteViewAnimation"];

    POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    alphaAnimation.toValue = @0;
    alphaAnimation.duration = 0.2;
    alphaAnimation.removedOnCompletion = YES;
    [self.inviteView.layer pop_addAnimation:alphaAnimation forKey:@"alphaAnimation"];

    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH * 0.5, (SCREEN_HEIGHT - 240.0))];
    anim.springBounciness = 4.0;
    anim.springSpeed = 8.0;
    anim.removedOnCompletion = YES;
    anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            [_inviteView removeFromSuperview];
        }
    };
    [self.mapImageVIew.layer pop_addAnimation:anim forKey:@"MoveMap"];

    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.9)];
    scaleAnimation.removedOnCompletion = YES;
    [self.mapImageVIew.layer pop_addAnimation:scaleAnimation forKey:@"Scale"];

    [self showTableView];
}

-(void)doInviteEmail:(NSString *)email
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"email": email,
                                 @"user_token":[GVUserDefaults standardUserDefaults].token
                                 };
    [manager POST:[NSString stringWithFormat:@"%@%@",[[VPNStations sharedInstance].config valueForKey:@"server"], [[VPNStations sharedInstance].config valueForKey:@"do_invite"]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
#ifdef DEBUG
        NSLog(@"JSON: %@", responseObject);
#endif
        
        NSString * message = [responseObject valueForKey:@"message"];
        NSString * status = [responseObject valueForKey:@"status"];
        if([status isEqualToString:@"error"]){
            [SVProgressHUD showErrorWithStatus:message];
        }else{
            [SVProgressHUD showSuccessWithStatus:message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

#ifdef DEBUG
        NSLog(@"Error: %@", error);
#endif
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // time-consuming task
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:[error description]];
            });
        });
    }];

}

- (void)validateUser
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"user_token":[GVUserDefaults standardUserDefaults].token
                                 };
    [manager POST:[NSString stringWithFormat:@"%@%@",[[VPNStations sharedInstance].config valueForKey:@"server"], [[VPNStations sharedInstance].config valueForKey:@"validate_user"]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

#ifdef DEBUG
        NSLog(@"JSON: %@", responseObject);
#endif

        NSString * status = [responseObject valueForKey:@"status"];
        if([status isEqualToString:@"error"]){

            [GVUserDefaults standardUserDefaults].token = nil;
            NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.catchlab.TodayExtensionSharingDefaults"];
            
            [sharedDefaults setBool:NO forKey:@"ActiveToday"];
            [sharedDefaults synchronize];   // (!!) This is crucial.
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

#ifdef DEBUG
        NSLog(@"Error: %@", error);
#endif
    }];
}

@end
