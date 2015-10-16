//
//  ECLiteDBApp.m
//  ECLiteDatabase
//
//  Created by qinwenzhou on 15/1/21.
//  Copyright (c) 2015年 ec. All rights reserved.
//

#import "ECLiteDBApp.h"
#import "ECLiteColoumn.h"

// 表名
#define ECLiteDB_App   @"App"

@implementation ECLiteDBApp
/*
- (id)copyWithZone:(NSZone *)zone
{
    ECLiteDBApp *copyApp = [[ECLiteDBApp allocWithZone:zone] init];
    copyApp.firstStart = _firstStart;
    copyApp.lastUserID = _lastUserID;
    copyApp.appVerson = _appVerson;
    copyApp.appStoreVersion = [_appStoreVersion copy];
    copyApp.dbVersion = _dbVersion;
    return copyApp;
}

+ (NSString *)tableName
{
    return ECLiteDB_App;
}

+ (NSArray *)coloumns
{
    NSMutableArray *cols = [NSMutableArray array];
    
    ECLiteColoumn *col = [ECLiteColoumn initWithSqlColumnName:app_firstStart sqlColumnType:SqlTypeInteger propertyName:@"firstStart"];
    [cols addObject:col];
    
    col = [ECLiteColoumn initWithSqlColumnName:app_lastUserID sqlColumnType:SqlTypeInteger propertyName:@"lastUserID"];
    [cols addObject:col];
    
    col = [ECLiteColoumn initWithSqlColumnName:app_appVersion sqlColumnType:SqlTypeInteger propertyName:@"appVerson"];
    [cols addObject:col];
    
    col = [ECLiteColoumn initWithSqlColumnName:app_appStoreVersion sqlColumnType:SqlTypeText propertyName:@"appStoreVersion"];
    [cols addObject:col];
    
    col = [ECLiteColoumn initWithSqlColumnName:app_dbVersion sqlColumnType:SqlTypeInteger propertyName:@"dbVersion"];
    [cols addObject:col];
    
    return cols;
}
 */
@end
