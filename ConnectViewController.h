//
//  ConnectViewController.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/19/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkSpaceManager.h"

@interface ConnectViewController : UIViewController

@property (nonatomic) BOOL isFromMapOrAR;
//-(void) initNetworkCommunication;
@property (strong, nonatomic) WorkSpaceModel    *connectWs;

@end
