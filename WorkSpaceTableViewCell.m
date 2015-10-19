//
//  WorkSpaceTableViewCell.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/17/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "WorkSpaceTableViewCell.h"

@implementation WorkSpaceTableViewCell

- (void)awakeFromNib {
    // Initialization code
//    [self.imageView setUserInteractionEnabled:YES];
//    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
//    [singleTap setNumberOfTapsRequired:1];
//    [self.imageView addGestureRecognizer:singleTap];
}
//
//-(void) singleTapping:(UIGestureRecognizer*) gr {
//    if (gr.state == UIGestureRecognizerStateEnded) {
//        statements
//    }
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
