//
//  ServiceTableViewCell.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/18/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
#import <FlatUIKit.h>
#import "ServiceModel.h"

@interface ServiceTableViewCell : SWTableViewCell
@property (nonatomic) int id;
@property (nonatomic) SERVICE_TYPE type;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet FUIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIImageView *connectedGreen;

@end
