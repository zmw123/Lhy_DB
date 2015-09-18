//
//  ECLiteDB.m
//  DBTest
//
//  Created by Apple on 15/6/4.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "ECLiteDB.h"
#import "FMDB.h"
#import <objc/runtime.h>
#import "ECLiteColoumn.h"
#import "ECLiteDatabase.h"
#import "FMDB.h"
#import <objc/runtime.h>


static NSString* const Attribute_NotNull     =   @"NOT NULL";
static NSString* const Attribute_PrimaryKey  =   @"PRIMARY KEY";
static NSString* const Attribute_primaryKeyAuto = @"PRIMARY KEY AUTOINCREMENT";
static NSString* const Attribute_Default     =   @"DEFAULT";
static NSString* const Attribute_Unique      =   @"UNIQUE";
static NSString* const Attribute_Check       =   @"CHECK";
static NSString* const Attribute_ForeignKey  =   @"FOREIGN KEY";

//static char Base_Key_RowID;
static NSString *tableName;
static NSArray *primaryKey;
static NSArray *coloumns;
@interface ECLiteDB()
//@property (strong, nonatomic) NSString *tableName;
//@property (strong, nonatomic) NSArray *primaryKey;
//@property (strong, nonatomic) NSArray *coloumns;
@end

@implementation ECLiteDB

- (id)init
{
    self = [super init];
    if (self && tableName.length <= 0)
    {
        tableName = [[self class] tableName];
        coloumns = [[self class] coloumns];
        primaryKey = [[self class] primaryKey];
    }
    return self;
}

+ (NSString *)tableName
{
    return nil;
}

+ (NSArray *)coloumns
{
    return nil;
}

+ (NSArray *)primaryKey
{
    ECLiteColoumn *col = [ECLiteColoumn initWithSqlColumnName:@"rowid" sqlColumnType:SqlTypeInteger propertyName:@"rowID"];
    return @[col];
}

#pragma mark - 数据库操作
+ (BOOL)createTable
{
    if (tableName.length <= 0)
    {
        tableName = [[self class] tableName];
        coloumns = [[self class] coloumns];
        primaryKey = [[self class] primaryKey];
    }
    
    NSMutableString *table_pars = [NSMutableString string];
    
    for (NSInteger i = 0; i < coloumns.count; i++)
    {
        if (i > 0)
        {
            [table_pars appendString:@","];
        }
        
        ECLiteColoumn *property = [coloumns objectAtIndex:i];
        
        NSString *columnType = [property sqlColumnTypeStr];
        
        [table_pars appendFormat:@"%@ %@", property.sqlColumnName, columnType];
        
        if (property.sqlColumnType == SqlTypeText)
        {
            if (property.length > 0)
            {
                [table_pars appendFormat:@"(%ld)", (long)property.length];
            }
        }
        
        if (property.isNotNull)
        {
            [table_pars appendFormat:@" %@", Attribute_NotNull];
        }
        
        if (property.isUnique)
        {
            [table_pars appendFormat:@" %@", Attribute_Unique];
        }
        
        if (property.checkValue)
        {
            [table_pars appendFormat:@" %@(%@)", Attribute_Check, property.checkValue];
        }
        
        if (property.defaultValue)
        {
            [table_pars appendFormat:@" %@ %@", Attribute_Default, property.defaultValue];
        }
    }
        
    ECLiteColoumn *property = [primaryKey lastObject];
    if (property)
    {
        [table_pars appendString:@","];
        NSString *columnType = [property sqlColumnTypeStr];
        
        [table_pars appendFormat:@"%@ %@", property.sqlColumnName, columnType];
        
        [table_pars appendFormat:@" %@ ", Attribute_primaryKeyAuto];
    }
    
    
    NSString *createTableSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@)", self.tableName, table_pars];
    
    __block BOOL isCreated;
    
    [[ECLiteDatabase instance].dbQueue inDatabase:^(FMDatabase *db) {
        
        isCreated = [db executeUpdate:createTableSQL];
        if (!isCreated)
        {
            NSLog(@"%@建表失败", self.tableName);
        }
    }];
    
    return isCreated;
}

+ (void)insertAll:(NSArray *)data
{
    [[ECLiteDatabase instance].dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (id object in data)
        {
            NSArray *argu = [self insertSql:object];
            NSString *insertSQL = [argu firstObject];
            NSArray *insertValues = [argu lastObject];
            BOOL success = [db executeUpdate:insertSQL withArgumentsInArray:insertValues];
            if (!success)
            {
                NSLog(@"插入%@失败", tableName);
            }
            else
            {
                NSString *sql    = [NSString stringWithFormat:@"select last_insert_rowid() as id from %@", tableName];
                FMResultSet *set = [db executeQuery:sql];
                while ([set next])
                {
                    id rowid = [set objectForColumnName:@"id"];
                    ECLiteColoumn *col = primaryKey.lastObject;
                    struct objc_property *pro =  class_getProperty([object class], col.propertyName.UTF8String);
                    if (pro != NULL)
                    {
                        
                    }
                    [object setValue:rowid forKey:col.propertyName];
                }
                [set close];
                set = nil;
            }
        }
    }];
}

+ (NSArray *)insertSql:(id)object
{
    NSMutableString *insertKey = [NSMutableString stringWithCapacity:0];
    NSMutableString *insertValuesString = [NSMutableString stringWithCapacity:0];
    NSMutableArray *insertValues = [NSMutableArray arrayWithCapacity:coloumns.count];
    
    for (NSInteger i = 0; i < coloumns.count; i++)
    {
        ECLiteColoumn *property = [coloumns objectAtIndex:i];
        
        id oneValues = nil;
        if (property.sqlColumnType == SqlTypeBlob)
        {
            oneValues = [NSKeyedArchiver archivedDataWithRootObject:[object valueForKey:property.propertyName]];
        }
        else
        {
            oneValues = [object valueForKey:property.propertyName];
        }
        
        if (oneValues)
        {
            if (insertKey.length > 0)
            {
                [insertKey appendString:@","];
                [insertValuesString appendString:@","];
            }
            
            [insertKey appendString:property.sqlColumnName];
            [insertValuesString appendString:@"?"];
            [insertValues addObject:oneValues];
        }
    }
    
    // 拼接insertSQL 语句
    NSString *insertSQL = [NSString stringWithFormat:@"insert into %@(%@) values(%@)", tableName, insertKey, insertValuesString];
    return @[insertValues, insertSQL];
}

- (BOOL)insert
{
    NSArray *argu = [[self class] insertSql:self];
    // 拼接insertSQL 语句
    NSString *insertSQL = [argu lastObject];
    NSArray *insertValues = [argu firstObject];
    
    __block BOOL success;
    
    [[ECLiteDatabase instance].dbQueue inDatabase:^(FMDatabase *db) {
        
        BOOL success = [db executeUpdate:insertSQL withArgumentsInArray:insertValues];
        if (!success)
        {
            NSLog(@"插入%@失败", tableName);
        }
        else
        {
            NSString *sql    = [NSString stringWithFormat:@"select last_insert_rowid() as id from %@", tableName];
            FMResultSet *set = [db executeQuery:sql];
            while ([set next])
            {
                id rowid = [set objectForColumnName:@"id"];
                ECLiteColoumn *col = primaryKey.lastObject;
                [self setValue:rowid forKey:col.propertyName];
            }
        }
    }];
    return success;
}

- (BOOL)update
{
    NSMutableString *updateKey = [NSMutableString string];
    NSMutableArray *updateValues = [NSMutableArray arrayWithCapacity:coloumns.count];
    
    for (NSInteger i = 0; i < coloumns.count; i++)
    {
        ECLiteColoumn *property = [coloumns objectAtIndex:i];
        
        if (updateKey.length > 0)
        {
            [updateKey appendString:@","];
        }
        
        [updateKey appendFormat:@"%@=?", property.sqlColumnName];
        
        [updateValues addObject:[self valueForKey:property.propertyName]];
    }
    
    NSMutableString *updateSQL = [NSMutableString stringWithFormat:@"update %@ set %@", tableName, updateKey];
    
    if (primaryKey.count > 0)
    {
        [updateSQL appendString:@" where "];
    }
    // 添加where 语句
    for (NSInteger i = 0; i < primaryKey.count; i++)
    {
        ECLiteColoumn *property = [primaryKey objectAtIndex:i];
        
        
        if (i > 0)
        {
            [updateSQL appendString:@" AND "];
        }
        
        [updateSQL appendFormat:@" %@ = ?", property.sqlColumnName];
        
        [updateValues addObject:[self valueForKey:property.propertyName]];
    }
    
    __block BOOL success;
    [[ECLiteDatabase instance].dbQueue inDatabase:^(FMDatabase *db) {
        
        if (updateValues.count > 0)
        {
            success = [db executeUpdate:updateSQL withArgumentsInArray:updateValues];
        }
        else
        {
            success = [db executeUpdate:updateSQL];
        }
    }];
    
    return success;
}

- (BOOL)remove
{
    NSMutableString *deleteSQL = [NSMutableString stringWithFormat:@"delete from %@ ", tableName];
    
    if (primaryKey.count > 0)
    {
        [deleteSQL appendString:@" where "];
    }
    // 添加where 语句
    NSMutableArray *updateWhereValue = [NSMutableArray array];
    for (NSInteger i = 0; i < primaryKey.count; i++)
    {
        ECLiteColoumn *property = [primaryKey objectAtIndex:i];
        
        if (i > 0)
        {
            [deleteSQL appendString:@" AND "];
        }
        
        [deleteSQL appendFormat:@" %@ = ?", property.sqlColumnName];
        
        [updateWhereValue addObject:[self valueForKey:property.propertyName]];
    }
    
    __block BOOL success;
    [[ECLiteDatabase instance].dbQueue inDatabase:^(FMDatabase *db) {
        
        if (updateWhereValue.count > 0)
        {
            success = [db executeUpdate:deleteSQL withArgumentsInArray:updateWhereValue];
        }
        else
        {
            success = [db executeUpdate:deleteSQL];
        }
    }];
    
    return success;
}

+ (NSArray *)dbWithSqlWhere:(NSString *)sql
{
    __block NSMutableArray *objects = [NSMutableArray array];
    [[ECLiteDatabase instance].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@", self.tableName];
        
        if (sql.length > 0)
        {
            sqlStr = [sqlStr stringByAppendingFormat:@" WHERE %@ ", sql];
        }
        FMResultSet *rs = [db executeQuery:sqlStr];
        while ([rs next])
        {
            NSDictionary *dic = rs.resultDictionary;
            
            Class class = [self class];
            id object = [[class alloc] init];
            
            for (ECLiteColoumn *col in self.coloumns)
            {
                id value = dic[col.sqlColumnName];
                if (col.sqlColumnType == SqlTypeBlob)
                {
                    value = [NSKeyedUnarchiver unarchiveObjectWithData:value];
                }
                [object setValue:value forKey:col.propertyName];
            }
            
            ECLiteColoumn *col = self.primaryKey.lastObject;
            id value = dic[col.sqlColumnName];
            [object setValue:value forKey:col.propertyName];
            
            [objects addObject:object];
        }
        [rs close];
        rs = nil;
    }];
    
    return objects;
}

+(BOOL)removeRepeat:(NSString *)keyName
{
    __block BOOL success;
    [[ECLiteDatabase instance].dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ IN (SELECT %@ FROM %@ GROUP BY %@ HAVING count(%@) > 1) AND rowid NOT IN (SELECT max(rowid) FROM %@ GROUP BY %@ HAVING count(%@) > 1)", tableName, keyName, keyName, tableName, keyName, keyName, tableName, keyName, keyName];
        success = [db executeUpdate:sql];
        if (!success)
        {
            NSLog(@"插入crm失败");
        }
    }];
    return success;
}
@end
