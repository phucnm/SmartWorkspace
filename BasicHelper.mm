//
//  BasicHelper.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/29/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "BasicHelper.h"
#include "BasicEncrypt.h"

@implementation BasicHelper

+ (instancetype)sharedHelper {
    static BasicHelper *sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[self alloc] init];
    });
    return sharedHelper;
}

-(NSString *)encrypt:(NSString *)obj {
    // Create data object from the string
    NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
    
    // Get pointer to data to obfuscate
    char *dataPtr = (char *) [data bytes];
    
    // Get pointer to key data
    char *keyData = (char *) [[self.key dataUsingEncoding:NSUTF8StringEncoding] bytes];
    
    // Points to each char in sequence in the key
    char *keyPtr = keyData;
    int keyIndex = 0;
    
    // For each character in data, xor with current value in key
    for (int x = 0; x < [data length]; x++)
    {
        // Replace current character in data with
        // current character xor'd with current key value.
        // Bump each pointer to the next character
        *dataPtr = *dataPtr ^ *keyPtr++;
        dataPtr++;
        
        // If at end of key data, reset count and
        // set key pointer back to start of key value
        if (++keyIndex == [self.key length])
            keyIndex = 0, keyPtr = keyData;
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

-(NSObject *)decrypt:(NSObject *)obj {
    return [self encrypt:obj];
}

-(NSString*) encryptCPP:(NSString*)message {
    string stdStr = string([message UTF8String]);
    string res = BasicEncHelper::encrypt(stdStr);
    const char* resC = res.c_str();
    return [NSString stringWithCString:resC encoding:NSASCIIStringEncoding];
}

-(instancetype)init {
    self = [super init];
    if (self) {
        self.key = @"$#&";
    }
    return self;
}

@end
