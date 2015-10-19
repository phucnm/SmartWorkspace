//
//  ServiceConnectHelper.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/19/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "ServiceConnectHelper.h"

@implementation ServiceConnectHelper

-(id) initWithService:(NSString *)name {
    self = [super init];
    
    if (self) {
        self.serviceName = name;
    }
    
    return self;
}

-(BOOL)isConnected {
    //TODO: implement here use NSUserDefaults
    BOOL res = [[NSUserDefaults standardUserDefaults] boolForKey:self.serviceName];
    
    return res;
}

-(void) logOut{
    
}

-(NSString *)getAccessToken {
    NSString *requestStr = [NSString stringWithFormat:@"%@_AccessToken", self.serviceName];
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:requestStr]) {
        return [[NSUserDefaults standardUserDefaults] stringForKey:requestStr];
    }
    
    return @"Not support";
}

-(NSString*)getAccessTokenSecret {
    NSString *requestStr = [NSString stringWithFormat:@"%@_AccessTokenSecret", self.serviceName];
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:requestStr]) {
        return [[NSUserDefaults standardUserDefaults] stringForKey:requestStr];
    }
    
    return @"Not support";
}

@end
