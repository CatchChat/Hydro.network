//
//  VCIPsecVPNManager.m
//  VPNCloud
//
//  Created by kevinzhow on 14/11/12.
//  Copyright (c) 2014年 Kingaxis Inc. All rights reserved.
//

#import "VCIPsecVPNManager.h"
#import "VCKetChain.h"

static NSString * const IKEv1ServiceName = @"Hydro VPN";
static NSString * const IKEv2ServiceName = @"Hydro IKEv2 VPN";

@implementation VCIPsecVPNManager

-(id)init
{
    self = [super init];
    if (self) {
        self.vpnManager = [NEVPNManager sharedManager];

    }
    return  self;
    
}



-(void)prepareWithCompletion:(void (^)(NSError *))done
{
    // init VPN manager
    
    
    [_vpnManager loadFromPreferencesWithCompletionHandler:^(NSError *error) {
        
        [self updateServiceStatus];
        
        done(error);
        
    }];

}

-(void)updateServiceStatus
{
//    NSLog(@"VPN is %@ %@",_vpnManager.protocol, [_vpnManager.protocol description]);
    if ([[[self.vpnManager.protocol valueForKey:@"type"] description] isEqualToString:@"5"]) {
        self.IKEv2Enabled = YES;
        self.IKEv1Enabled = NO;
    }else if ([[[self.vpnManager.protocol valueForKey:@"type"] description] isEqualToString:@"1"]){
        self.IKEv2Enabled = NO;
        self.IKEv1Enabled = YES;
    }
}

-(void)connectIPSecIKEv2WithHost:(NSString *)host andUsername:(NSString *)username andPassword:(NSString *)password andPSK:(NSString *)psk andGroupName:(NSString *)groupName

{
    VCKetChain * keychain =[[VCKetChain alloc] initWithService:@"VPNIKEv2PSK" withGroup:nil];
    
    NSString *key =@"password";
    NSData * value = [password dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *key2 =@"psk";
    NSData * value2 = [psk dataUsingEncoding:NSUTF8StringEncoding];
    
    if(![keychain find:@"password"] || ![keychain find:@"psk"])
    {
        if ([keychain insert:key :value]) {
            NSLog(@"Successfully added data");
        }else{
            NSLog(@"Failed to  add data");
        }
        
        if ([keychain insert:key2 :value2]) {
            NSLog(@"Successfully added data shared key");
        }else{
            NSLog(@"Failed to  add data shared key");
        }
        
    }
    else
    {
        NSLog(@"No need to  add data");
    }
    
    
    NEVPNProtocolIKEv2 *p = [[NEVPNProtocolIKEv2 alloc] init];
    p.username = username;
    p.serverAddress = host;
    p.passwordReference = [keychain find:@"password"];
    
    
    p.authenticationMethod = NEVPNIKEAuthenticationMethodSharedSecret;
    p.sharedSecretReference = [keychain find:@"psk"];
    
    p.localIdentifier = groupName;
    p.remoteIdentifier = host;
    
    p.useExtendedAuthentication = YES;
    p.disconnectOnSleep = NO;
    
    _vpnManager.protocol = p;
    _vpnManager.localizedDescription = IKEv2ServiceName;
    _vpnManager.enabled = YES;
    
    
    //    NEOnDemandRuleConnect *connectRule = [NEOnDemandRuleConnect new];
    //    connectRule.interfaceTypeMatch = NEOnDemandRuleInterfaceTypeCellular | NEOnDemandRuleInterfaceTypeWiFi;
    //
    //
//    NEOnDemandRuleEvaluateConnection * domainRule = [NEOnDemandRuleEvaluateConnection new];
//    
//    NEEvaluateConnectionRule * domainMatch = [[NEEvaluateConnectionRule alloc]
//                                              initWithMatchDomains:
//                                              @[@"*.twitter.com", @"www.twitter.com", @"*.google.com", @"*.google.com.hk", @"*.youtube.com",
//                                                @"*.googleusercontent.com",@"*.gstatic.com", @"*.ggpht.com",@"*.appspot.com", @"*.googleapis.com", @"*.google.cn",
//                                                @"*.fbcdn.net", @"*.staticflickr.com", @"*.twimg.com", @"*.ytimg.com", @"*.feedly.com",@"*.tinypic.com", @"*.instagram.com"] andAction:NEEvaluateConnectionRuleActionConnectIfNeeded];
//    domainRule.connectionRules = @[domainMatch];
//    
//    
//    [_vpnManager setOnDemandRules:@[domainRule]];
    
    //    _vpnManager.onDemandEnabled = YES;
    
    [_vpnManager saveToPreferencesWithCompletionHandler:^(NSError *error) {

#ifdef DEBUG
        NSLog(@"Save config failed [%@]", error.localizedDescription);
#endif
        if (!error) {
#ifdef DEBUG
            NSLog(@"username: %@", [_vpnManager protocol].username);
            NSLog(@"password: %@ %@", [_vpnManager protocol].passwordReference, [keychain find:@"password"]);
#endif
        }
        
        NSError *startError;
        [_vpnManager.connection startVPNTunnelAndReturnError:&startError];
        if (startError) {
            
#ifdef DEBUG
            NSLog(@"Start VPN failed: [%@]", startError.localizedDescription);
#endif
        }
    }];
}


-(void)connectIPSecIKEv2WithHost:(NSString *)host andUsername:(NSString *)username andPassword:(NSString *)password andP12Name:(NSString *)p12Name andidentityDataPassword:(NSString *)identityDataPassword andGroupName:(NSString *)groupName
{
    
    VCKetChain * keychain =[[VCKetChain alloc] initWithService:@"VPNIKEv2" withGroup:nil];
    
    NSString *key =@"password";
    NSData * value = [password dataUsingEncoding:NSUTF8StringEncoding];
    
    if(![keychain find:@"password"])
    {
        if ([keychain insert:key :value]) {
            NSLog(@"Successfully added data");
        }else{
            NSLog(@"Failed to  add data");
        }
        
    }
    else
    {
        NSLog(@"No need to  add data");
    }
    
    
    NEVPNProtocolIKEv2 *p = [[NEVPNProtocolIKEv2 alloc] init];
    p.username = username;
    p.serverAddress = host;
    p.serverCertificateIssuerCommonName = @"COMODO RSA Domain Validation Secure Server CA";
    p.serverCertificateCommonName = @"*.piner.me";
    p.passwordReference = [keychain find:@"password"];
    
    
    p.identityData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",p12Name] ofType:@"p12"]];
    p.identityDataPassword = identityDataPassword;
    p.authenticationMethod = NEVPNIKEAuthenticationMethodCertificate;
    
    p.localIdentifier = groupName;
    p.remoteIdentifier = host;
    
    p.useExtendedAuthentication = YES;
    p.disconnectOnSleep = NO;
    
    _vpnManager.protocol = p;
    _vpnManager.localizedDescription = IKEv2ServiceName;
    _vpnManager.enabled = YES;
    

//    NEOnDemandRuleConnect *connectRule = [NEOnDemandRuleConnect new];
//    connectRule.interfaceTypeMatch = NEOnDemandRuleInterfaceTypeCellular | NEOnDemandRuleInterfaceTypeWiFi;
//
//    
    NEOnDemandRuleEvaluateConnection * domainRule = [NEOnDemandRuleEvaluateConnection new];
    
    NEEvaluateConnectionRule * domainMatch = [[NEEvaluateConnectionRule alloc]
                                              initWithMatchDomains:
  @[@"*.twitter.com", @"www.twitter.com", @"*.google.com", @"*.google.com.hk", @"*.youtube.com",
    @"*.googleusercontent.com",@"*.gstatic.com", @"*.ggpht.com",@"*.appspot.com", @"*.googleapis.com", @"*.google.cn",
    @"*.fbcdn.net", @"*.staticflickr.com", @"*.twimg.com", @"*.ytimg.com", @"*.feedly.com",@"*.tinypic.com", @"*.instagram.com"] andAction:NEEvaluateConnectionRuleActionConnectIfNeeded];
    domainRule.connectionRules = @[domainMatch];
    
    
    [_vpnManager setOnDemandRules:@[domainRule]];
    
//    _vpnManager.onDemandEnabled = YES;
    
    [_vpnManager saveToPreferencesWithCompletionHandler:^(NSError *error) {

#ifdef DEBUG
        NSLog(@"Save config failed [%@]", error.localizedDescription);
#endif
        if (!error) {
#ifdef DEBUG
            NSLog(@"username: %@", [_vpnManager protocol].username);
            NSLog(@"password: %@ %@", [_vpnManager protocol].passwordReference, [keychain find:@"password"]);
#endif

        }
        
        NSError *startError;
        [_vpnManager.connection startVPNTunnelAndReturnError:&startError];
        if (startError) {

#ifdef DEBUG
            NSLog(@"Start VPN failed: [%@]", startError.localizedDescription);
#endif
        }
        
    }];

}


-(void)connectIPSecWithHost:(NSString *)host andUsername:(NSString *)username andPassword:(NSString *)password andPSK:(NSString *)psk andGroupName:(NSString *)groupName
{
    
    
    VCKetChain * keychain =[[VCKetChain alloc] initWithService:@"VPN" withGroup:nil];
    
    NSString *key =@"password";
    NSData * value = [password dataUsingEncoding:NSUTF8StringEncoding];
 
    NSString *key2 =@"psk";
    NSData * value2 = [psk dataUsingEncoding:NSUTF8StringEncoding];
    
    if(![keychain find:@"password"] || ![keychain find:@"psk"])
    {
        if ([keychain insert:key :value]) {
            NSLog(@"Successfully added data");
        }else{
            NSLog(@"Failed to  add data");
        }
        
        if ([keychain insert:key2 :value2]) {
            NSLog(@"Successfully added data shared key");
        }else{
            NSLog(@"Failed to  add data shared key");
        }
        
    }
    else
    {
        NSLog(@"No need to  add data");
    }
    
    
    NEVPNProtocolIPSec *p = [[NEVPNProtocolIPSec alloc] init];
    p.username = username;
    p.serverAddress = host;
    p.passwordReference = [keychain find:@"password"];
    
    // PSK
    p.authenticationMethod = NEVPNIKEAuthenticationMethodSharedSecret;
    p.sharedSecretReference = [keychain find:@"psk"];
    

    /*
     // certificate
     p.identityData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"client" ofType:@"p12"]];
     p.identityDataPassword = @"[Your certificate import password]";
     */
    
    p.remoteIdentifier = host;
    p.localIdentifier = groupName;
    
    p.useExtendedAuthentication = YES;
    p.disconnectOnSleep = NO;
    
    _vpnManager.protocol = p;
    _vpnManager.localizedDescription = IKEv1ServiceName;
    _vpnManager.enabled = YES;
    _vpnManager.onDemandEnabled = NO;


    NEOnDemandRuleConnect *connectRule = [NEOnDemandRuleConnect new];
    connectRule.interfaceTypeMatch = NEOnDemandRuleInterfaceTypeCellular | NEOnDemandRuleInterfaceTypeWiFi;

    
    
    [_vpnManager setOnDemandRules:@[connectRule]];

    
    [_vpnManager saveToPreferencesWithCompletionHandler:^(NSError *error) {

#ifdef DEBUG
        NSLog(@"Save config failed [%@]", error.localizedDescription);
#endif
        if (!error) {
#ifdef DEBUG
            NSLog(@"username: %@", [_vpnManager protocol].username);
            NSLog(@"password: %@ %@", [_vpnManager protocol].passwordReference, [keychain find:@"password"]);
            NSLog(@"sharedSecretReference: %@ %@", p.sharedSecretReference, [keychain find:@"psk"]);
#endif
            
            NSError *startError;
            [_vpnManager.connection startVPNTunnelAndReturnError:&startError];
            if (startError) {
                NSLog(@"Start VPN failed: [%@]", startError.localizedDescription);
            }
        }
    }];
    

}

@end
