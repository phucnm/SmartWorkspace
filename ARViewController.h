//
//  ARViewController.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/22/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ARViewController : UIViewController

@property (nonatomic, strong) NSArray *workSpaces;
@property (nonatomic, strong) MKUserLocation *userLocation;

@end
