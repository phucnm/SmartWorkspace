//
//  WorkSpaceTableViewCell.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/17/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>

@interface WorkSpaceTableViewCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbView;
@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet UILabel *dstLabel;

@end
