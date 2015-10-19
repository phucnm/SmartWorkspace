//
//  MarkerView.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/22/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkSpaceModel.h"

@class ARGeoCoordinate;
@protocol MarkerViewDelegate;

@interface MarkerView : UIView

//2
@property (nonatomic, strong) ARGeoCoordinate *coordinate;
@property (nonatomic, weak) id <MarkerViewDelegate> delegate;
@property (nonatomic, strong) WorkSpaceModel *ws;

//3
- (id)initWithCoordinate:(ARGeoCoordinate *)coordinate delegate:(id<MarkerViewDelegate>)delegate;

@end

//4
@protocol MarkerViewDelegate <NSObject>

- (void)didTouchMarkerView:(MarkerView *)markerView;

@end
