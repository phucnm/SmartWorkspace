//
//  ServiceModel.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 7/5/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "ServiceModel.h"

@implementation ServiceModel

- (instancetype) initWithType:(SERVICE_TYPE)type andName:(NSString*) name andIcon:(NSString*) icon {
    self = [super init];
    if (self) {
        self.type = type;
        self.name = name;
        self.icon_path = icon;
    }
    
    return self;
}

-(instancetype)encrypt {
    return self;
}

-(instancetype)decrypt{
    return self;
}
@end
