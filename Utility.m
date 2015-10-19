//
//  Utility.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 10/14/15.
//  Copyright © 2015 PHUCNGUYEN. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (NSString*) getImagesPath {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [documentsPath stringByAppendingPathComponent:IMAGES_PATH];
}

@end
