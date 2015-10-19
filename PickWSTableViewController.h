//
//  PickWSTableViewController.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 7/4/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PickWSDelegate;

@interface PickWSTableViewController: UITableViewController

@property (nonatomic, strong) NSArray *workspaces;
@property (nonatomic, strong) id<PickWSDelegate> delegate;
@end

@protocol PickWSDelegate

-(void) didSelectedWS:(int) index;

@end
