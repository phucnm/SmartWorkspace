//
//  MarkerView.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/22/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "MarkerView.h"
#import "ARGeoCoordinate.h"
#import "DistanceHelper.h"
#import "JPSThumbnailAnnotationView.h"
#import "NSString+Icons.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"

const float kWidth = 100.0f;
const float kHeight = 60.0f;

@interface MarkerView ()

@property (nonatomic, strong) UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dstLabel;

@end

@implementation MarkerView

- (id)initWithCoordinate:(ARGeoCoordinate *)coordinate delegate:(id<MarkerViewDelegate>)delegate {
    //1
    if((self = [super initWithFrame:CGRectMake(0.0f, 0.0f, kWidth, kHeight)])) {
        
        //2
        _coordinate = coordinate;
        _delegate = delegate;
        
        [self setUserInteractionEnabled:YES];
        
//        UIView *markerView = [[[NSBundle mainBundle] loadNibNamed:@"MarkerView" owner:self options:nil] firstObject];
//        self.titleLabel.text = [coordinate title];
//        self.dstLabel.text = [DistanceHelper stringWithDistance:[coordinate distanceFromOrigin]];
//        self.imageView.image = coordinate.image;
//        return markerView;
        
        UIImage *tmp = coordinate.image;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 80.0f)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        //imageView.clipsToBounds = YES;
        imageView.image = tmp;
//        [imageView sizeToFit];
        
        
        //3
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(80, 0.0f, 50.0f, 40.0f)];
        //[title setBackgroundColor:[UIColor colorWithWhite:0.3f alpha:0.2f]];
        [title setTextColor:[UIColor whiteColor]];
        [title setTextAlignment:NSTextAlignmentCenter];
        NSString *titleText = [NSString stringWithFormat:@"%@ %@", [NSString iconStringForEnum:FUITag], [coordinate title]];
//        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:titleText];
//        
//        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor turquoiseColor] range:NSMakeRange(0, 1)];
//        
//        [attString addAttribute:NSFontAttributeName value:[UIFont iconFontWithSize:24] range:NSMakeRange(0, 1)];F
//        
//        [attString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:24] range:NSMakeRange(1,[[coordinate title] length] - 1)];
//        
//        [title setAttributedText:attString];
        [title setText:titleText];
        [title setFont:[UIFont iconFontWithSize:22]];
        [title sizeToFit];
        
        //4
        _lblDistance = [[UILabel alloc] initWithFrame:CGRectMake(80, 40.0f, 100.0f, 40.0f)];
        //[_lblDistance setBackgroundColor:[UIColor colorWithWhite:0.3f alpha:0.2f]];
        [_lblDistance setTextColor:[UIColor whiteColor]];
        [_lblDistance setTextAlignment:NSTextAlignmentCenter];
        NSString *dstText = [NSString stringWithFormat:@"%@ %@", [NSString iconStringForEnum:FUILocation], [DistanceHelper stringWithDistance:[coordinate distanceFromOrigin]]];
        [_lblDistance setText:dstText];
        [_lblDistance setFont:[UIFont iconFontWithSize:22]];
        [_lblDistance sizeToFit];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f + title.frame.size.width, imageView.frame.size.height)];
        [bgView setBackgroundColor:[UIColor colorWithWhite:0.3f alpha:0.2f]];
        
        //5
        [self addSubview:bgView];
        [self addSubview:imageView];
        [self addSubview:title];
        [self addSubview:_lblDistance];
        
        //[self setBackgroundColor:[UIColor greenColor]];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    NSString *dstText = [NSString stringWithFormat:@"%@ %@", [NSString iconStringForEnum:FUILocation], [DistanceHelper stringWithDistance:[[self coordinate] distanceFromOrigin]]];
    [_lblDistance setText:dstText];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_delegate && [_delegate conformsToProtocol:@protocol(MarkerViewDelegate)]) {
        [_delegate didTouchMarkerView:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
