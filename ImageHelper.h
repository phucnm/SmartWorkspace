//
//  ImageHelper.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/23/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageHelper : NSObject

+(id) sharedHelper;

+ (void) saveImage:(UIImage*)image to:(NSString*) path;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+ (UIImage *)scaleAndRotateImage:(UIImage *) image;

@end
