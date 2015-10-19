//
//  ServiceManager.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 7/7/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "ServiceManager.h"


@interface ServiceManager ()

@property (nonatomic, strong) FMDatabase *db;

@end

@implementation ServiceManager

+ (instancetype)sharedManager {
    static ServiceManager *sharedManager = nil;
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
        NSMutableArray *arrServices = [NSMutableArray array];
        FMResultSet *result = [self.db executeQuery:@"SELECT * FROM SERVICES"];
        while ([result next]) {
            ServiceModel *model = [[ServiceModel alloc] init];
            model.id = [result intForColumn:@"_id"];
            model.type = [result intForColumn:@"type"];
            model.name = [result stringForColumn:@"name"];
            model.icon_path = [result stringForColumn:@"icon_path"];
            model.access_token = [result stringForColumn:@"access_token"];
            model.access_token_secret = [result stringForColumn:@"access_token_secret"];
            model.username = [result stringForColumn:@"username"];
            model.password = [result stringForColumn:@"password"];
            [arrServices addObject:[model decrypt]];
        }
        [self.db close];
        return arrServices;
    }
    return nil;
}

- (BOOL)addOne:(ServiceModel *)model {
    if ([self.db open]) {
        model = [model encrypt];
        BOOL res = [self.db executeUpdate:@"INSERT INTO SERVICES(type, name, icon_path, access_token, access_token_secret, username, password) VALUES(?,?,?,?,?,?,?)", [NSNumber numberWithInteger:model.type], model.name, model.icon_path, model.access_token, model.access_token_secret, model.username, model.password];
        
        [self.db close];
        if (res)
            return YES;
    }
    return NO;
}

-(BOOL)updateOne:(ServiceModel*)model {
    if ([self.db open]) {
        model = [model encrypt];
        BOOL res = [self.db executeUpdate:@"UPDATE SERVICES SET username=?, password=? WHERE _id=?", model.username, model.password, [NSNumber numberWithInt:model.id]];
        
        [self.db close];
        if (res)
            return YES;
    }
    return NO;
}

-(BOOL)deleteOneWithId:(int) id {
    if ([self.db open]) {
        
        BOOL res = [self.db executeUpdate:@"DELETE FROM SERVICES WHERE _id = ? ", [NSNumber numberWithInt:id]];
        
        [self.db close];
        if (res)
            return YES;
    }
    return NO;
}


@end
