//
//  EncryptHelper.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/29/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncryptHelper : NSObject

@property (nonatomic, strong) NSString *key;

+ (instancetype)sharedHelper;
-(NSObject*) encrypt:(NSObject*) obj;
-(NSObject*) decrypt:(NSObject*) obj;

@end
