//
//  VCIPsecVPNManager.h
//  VPNCloud
//
//  Created by kevinzhow on 14/11/12.
//  Copyright (c) 2014年 Kingaxis Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>


@interface VCIPsecVPNManager : NSObject

@property (nonatomic) NEVPNManager * vpnManager;

-(void)prepareWithCompletion:(void (^)(NSError *error))done;

-(void)connectIPSecIKEv2WithHost:(NSString *)host andUsername:(NSString *)username andPassword:(NSString *)password andP12Name:(NSString *)p12Name andidentityDataPassword:(NSString *)identityDataPassword andGroupName:(NSString *)groupName;

-(void)connectIPSecWithHost:(NSString *)host andUsername:(NSString *)username andPassword:(NSString *)password andPSK:(NSString *)psk andGroupName:(NSString *)groupName;

-(void)connectIPSecIKEv2WithHost:(NSString *)host andUsername:(NSString *)username andPassword:(NSString *)password andPSK:(NSString *)psk andGroupName:(NSString *)groupName;

@property (nonatomic) BOOL IKEv1Enabled;

@property (nonatomic) BOOL IKEv2Enabled;

@end
