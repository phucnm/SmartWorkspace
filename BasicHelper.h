//
//  BasicHelper.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/29/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncryptHelper.h"

@interface BasicHelper : EncryptHelper
//@property (nonatomic, strong) NSString *key;
//+ (instancetype)sharedHelper;
//-(NSString*) encrypt:(NSString*) obj;
//-(NSString*) decrypt:(NSString*) obj;
-(NSString*) encryptCPP:(NSString*)message;
@end
