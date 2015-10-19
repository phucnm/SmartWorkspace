//
//  WSCreateViewController.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/23/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkSpaceModel.h"

@protocol WSCreateDelegate;

@interface WSCreateViewController : UIViewController

@property (nonatomic, strong) NSArray *workSpaces;
@property (nonatomic, strong) id<WSCreateDelegate> delegate;
@property (nonatomic) BOOL isCreateNew;
@property (nonatomic, strong) WorkSpaceModel *ws;
@end

@protocol WSCreateDelegate

-(void)didCreatedWS:(WorkSpaceModel*)ws;
-(void)didUpdatedWS:(WorkSpaceModel*)ws;

@end