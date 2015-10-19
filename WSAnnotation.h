//
//  WSAnnotation.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/22/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface WSAnnotation : NSObject <MKAnnotation>

@property (copy, nonatomic) NSString *title;
@property (nonatomic) CLLocationCoordinate2D coordinate;

-(id) initWithTitle:(NSString*) title AndCoordinate:(CLLocationCoordinate2D) coordinate;

@end
