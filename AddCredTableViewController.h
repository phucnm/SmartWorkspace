//
//  AddCredTableViewController.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 7/6/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceModel.h"

@interface AddCredTableViewController : UITableViewController

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) ServiceModel *service;

@end
