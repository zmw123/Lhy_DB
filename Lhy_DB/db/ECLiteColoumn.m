//
//  ECLiteColoumn.m
//  ECLiteCore
//
//  Created by Apple on 15/6/3.
//  Copyright (c) 2015年 ecqq. All rights reserved.
//

#import "ECLiteColoumn.h"

@implementation ECLiteColoumn

+ (instancetype)initWithSqlColumnName:(NSString *)sqlColumnName sqlColumnType:(SqlType)sqlColumnType propertyName:(NSString *)propertyName isUnique:(BOOL)isUnique isNotNull:(BOOL)isNotNull defaultValue:(NSString *)defaultValue checkValue:(NSString *)checkValue length:(NSInteger)length
{
    ECLiteColoumn *col = [[ECLiteColoumn alloc] init];
    if (sqlColumnName.length <= 0)
    {
        return nil;
    }
    col.sqlColumnName = sqlColumnName;
    
    col.sqlColumnType = sqlColumnType;
    if (propertyName.length <= 0)
    {
        return nil;
    }
    col.propertyName = propertyName;
    
    col.isUnique = isUnique;
    col.isNotNull = isNotNull;
    
    col.defaultValue = defaultValue;
    
    col.checkValue = checkValue;
    
    col.length = length;
    
    return col;
}

+ (instancetype)initWithSqlColumnName:(NSString *)sqlColumnName sqlColumnType:(SqlType)sqlColumnType propertyName:(NSString *)propertyName
{
    ECLiteColoumn *col = [[ECLiteColoumn alloc] init];
    if (sqlColumnName.length <= 0)
    {
        return nil;
    }
    col.sqlColumnName = sqlColumnName;
    
    col.sqlColumnType = sqlColumnType;
    if (propertyName.length <= 0)
    {
        return nil;
    }
    col.propertyName = propertyName;
    
    return col;
}

- (NSString *)sqlColumnTypeStr
{
    switch (self.sqlColumnType)
    {
        case SqlTypeText:
            return @"TEXT";
        case SqlTypeInteger:
            return @"INTEGER";
        case SqlTypeReal:
            return @"REAL";
        case SqlTypeBlob:
            return @"BLOB";
    }
}
@end
