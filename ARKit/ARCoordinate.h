//
//  ARCoordinate.h
//  AR Kit
//
//  Created by Zac White on 8/1/09.
//  Copyright 2009 Zac White. All rights reserved.
//

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * (180.0/M_PI))

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ARCoordinate : NSObject

- (NSUInteger) hash;
- (BOOL) isEqual:(id)other;
- (BOOL) isEqualToCoordinate:(ARCoordinate *) otherCoordinate;

+ (ARCoordinate *)coordinateWithRadialDistance:(double)newRadialDistance inclination:(double)newInclination azimuth:(double)newAzimuth;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, copy  ) NSString *subtitle;
@property (nonatomic        ) double   radialDistance;
@property (nonatomic        ) double   inclination;
@property (nonatomic        ) double   azimuth;
@property (nonatomic        ) UIImage  *image;
@property (nonatomic        ) int      _id;

@end
