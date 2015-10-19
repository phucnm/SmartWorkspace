//
//  WorkSpaceTableView.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/26/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "WorkSpaceTableView.h"

@implementation WorkSpaceTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id hitView = [super hitTest:point withEvent:event];
    if (point.y<0) {
        return nil;
    }
    return hitView;
}

@end
