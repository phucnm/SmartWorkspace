//
//  WSPopupViewController.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/25/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "WSPopupViewController.h"
#import "JPSThumbnailAnnotation.h"

@interface WSPopupViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation WSPopupViewController

bool isSmall = YES;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView addGestureRecognizer:singleTap];
    self.imageView.image = [UIImage imageNamed:[[Utility getImagesPath] stringByAppendingPathComponent:self.ws.image_path]];
    
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.ws.lat, self.ws.lon), 1200, 1200);
    //    self.location = userLocation;
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:NO];
    
    
    JPSThumbnail *thumbnail = [[JPSThumbnail alloc] init];
    thumbnail.image = [UIImage imageNamed:[[Utility getImagesPath] stringByAppendingPathComponent:self.ws.thumb_path]];
    thumbnail.title = self.ws.name;
    //thumbnail.subtitle = @"NYC Landmark";
    thumbnail.coordinate = CLLocationCoordinate2DMake(self.ws.lat, self.ws.lon);
    thumbnail.disclosureBlock = ^{ NSLog(@"selected"); };
    
    [self.mapView addAnnotation:[JPSThumbnailAnnotation annotationWithThumbnail:thumbnail]];
}

-(void)tapDetected{
    if (isSmall) {
        [UIView animateWithDuration:1.0f animations:^{
            [self.imageView setFrame:CGRectMake(0, 0, 320, 450)];
        }];
        isSmall = NO;
    } else {
        [UIView animateWithDuration:1.0f animations:^{
            [self.imageView setFrame:CGRectMake(0, 0, 320, 200)];
        }];
        isSmall = YES;
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
