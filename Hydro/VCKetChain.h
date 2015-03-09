//
//  VCKetChain.h
//  VPNCloud
//
//  Created by kevinzhow on 14/11/12.
//  Copyright (c) 2014年 Kingaxis Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCKetChain : NSObject
{
    NSString * service;
    NSString * group;
}
-(id) initWithService:(NSString *) service_ withGroup:(NSString*)group_;

-(BOOL) insert:(NSString *)key : (NSData *)data;
-(BOOL) update:(NSString*)key :(NSData*) data;
-(BOOL) remove: (NSString*)key;
-(NSData*) find:(NSString*)key;

@end
