//
//  WorkSpaceManager.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/23/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "WorkSpaceManager.h"

@interface  WorkSpaceManager()


@property (nonatomic, strong) NSMutableArray *arrWorkSpaces;

@end

@implementation WorkSpaceManager

+ (instancetype)sharedManager {
    static WorkSpaceManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    AppDelegate *delegate = [AppDelegate sharedDelegate];
    self.db = delegate.db;
    return self;
}

- (NSArray*)selectAll {
    if ([self.db open]) {
        self.arrWorkSpaces = [NSMutableArray array];
        FMResultSet *result = [self.db executeQuery:@"SELECT * FROM WORKSPACES"];
        while ([result next]) {
            WorkSpaceModel *model = [[WorkSpaceModel alloc] init];
            model.id = [result intForColumn:@"_id"];
            model.name = [result stringForColumn:@"name"];
            model.image_path = [result stringForColumn:@"image_path"];
            model.thumb_path = [result stringForColumn:@"thumb_path"];
            model.username = [result stringForColumn:@"username"];
            model.password = [result stringForColumn:@"password"];
            model.ipaddr = [result stringForColumn:@"ipaddr"];
            model.lon = [result doubleForColumn:@"lon"];
            model.lat = [result doubleForColumn:@"lat"];
            model.computer_name = [result stringForColumn:@"computer_name"];
            //model.address = [result stringForColumn:@"address"];
            [self.arrWorkSpaces addObject:[model decrypt]];
        }
        [self.db close];
        return self.arrWorkSpaces;
    }
    return nil;
}

- (BOOL)addOne:(WorkSpaceModel *)ws {
    if ([self.db open]) {
        ws = [ws encrypt];
        BOOL res = [self.db executeUpdate:@"INSERT INTO WORKSPACES(name, image_path, thumb_path, username, password, ipaddr, lon, lat, computer_name) VALUES(?,?,?,?,?,?,?,?,?)", ws.name, ws.image_path, ws.thumb_path, ws.username, ws.password, ws.ipaddr, [NSNumber numberWithDouble:ws.lon], [NSNumber numberWithDouble:ws.lat], ws.computer_name];
        
        [self.db close];
        if (res)
            return YES;
    }
    return NO;
}

-(BOOL)updateOne:(WorkSpaceModel*)ws {
    if ([self.db open]) {
        ws = [ws encrypt];
        BOOL res = [self.db executeUpdate:@"UPDATE WORKSPACES SET name=?, image_path=?, thumb_path=?, username=?, password=?, ipaddr=?, lon=?, lat=?, computer_name = ? WHERE _id=?", ws.name, ws.image_path, ws.thumb_path, ws.username, ws.password, ws.ipaddr, [NSNumber numberWithDouble:ws.lon], [NSNumber numberWithDouble:ws.lat], ws.computer_name, [NSNumber numberWithInt:ws.id]];
        
        [self.db close];
        if (res)
            return YES;
    }
    return NO;
}

-(BOOL)deleteOneWithName:(NSString *)name {
    if ([self.db open]) {
        
        BOOL res = [self.db executeUpdate:@"DELETE FROM WORKSPACES WHERE name = ? ", name];
        
        [self.db close];
        if (res)
            return YES;
    }
    return NO;
}

@end
