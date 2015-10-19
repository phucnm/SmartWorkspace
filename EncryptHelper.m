//
//  EncryptHelper.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/29/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "EncryptHelper.h"

@implementation EncryptHelper

+ (instancetype)sharedHelper {
    static EncryptHelper *sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[self alloc] init];
    });
    return sharedHelper;
}

-(NSObject *)encrypt:(NSObject *)obj {
    
    return nil;
}

-(NSObject *)decrypt:(NSObject *)obj {
    return nil;
}

@end
