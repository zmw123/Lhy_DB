//
//  Database.m
//  ECLite
//
//  Created by Apple on 15/1/18.
//  Copyright (c) 2015年 ec. All rights reserved.
//

#import "ECLiteDatabase.h"
#import "FMDB.h"

@implementation ECLiteDatabase

static ECLiteDatabase *instance = nil;

+ (ECLiteDatabase *)instance
{
    @synchronized(self) {
        if (instance == nil)
        {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        if (_dbQueue)
        {
            [_dbQueue close];
            _dbQueue = nil;
        }
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
    }
    return self;
}

- (NSString *)dbPath
{
    if (!_dbPath)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *applicationSupportDirectory = [paths lastObject];
        if (![[NSFileManager defaultManager] fileExistsAtPath:applicationSupportDirectory])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _dbPath = [applicationSupportDirectory stringByAppendingPathComponent:@"ECLite.sqlite"];
    }
    return _dbPath;
}

@end