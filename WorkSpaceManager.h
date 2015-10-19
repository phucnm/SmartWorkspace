//
//  WorkSpaceManager.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/23/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "WorkSpaceModel.h"

@interface WorkSpaceManager : NSObject {
}
@property (nonatomic, strong) FMDatabase *db;
+(id) sharedManager;
-(NSArray*) selectAll;
-(BOOL) addOne:(WorkSpaceModel*) ws;
-(BOOL) updateOne:(WorkSpaceModel*) ws;
-(BOOL) deleteOneWithName:(NSString*) name;
@end
