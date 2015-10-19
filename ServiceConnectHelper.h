//
//  ServiceConnectHelper.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/19/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceConnectHelper : NSObject

@property (strong, nonatomic) NSString *serviceName;

-(id) initWithService:(NSString*) name;

-(BOOL) isConnected;

-(NSString*) getAccessToken;

-(NSString*) getAccessTokenSecret;

@end
