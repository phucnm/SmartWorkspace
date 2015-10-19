//
//  WSAnnotation.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/22/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "WSAnnotation.h"

@implementation WSAnnotation

-(id)initWithTitle:(NSString *)title AndCoordinate:(CLLocationCoordinate2D)coordinate {
    
    self = [super init];
    
    self.title = title;
    self.coordinate = coordinate;
    
    return self;
}

@end
