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
#import <UIKit/UIKit.h>


static NSString* const Attribute_NotNull     =   @"NOT NULL";
static NSString* const Attribute_PrimaryKey  =   @"PRIMARY KEY";
static NSString* const Attribute_primaryKeyAuto = @"PRIMARY KEY AUTOINCREMENT";
static NSString* const Attribute_Default     =   @"DEFAULT";
static NSString* const Attribute_Unique      =   @"UNIQUE";
static NSString* const Attribute_Check       =   @"CHECK";
static NSString* const Attribute_ForeignKey  =   @"FOREIGN KEY";

static NSString *tableName;
static NSArray *primaryKey;
static NSArray *coloumns;
@interface ECLiteDB()

@end

@implementation ECLiteDB
- (id)copyWithZone:(NSZone *)zone
{
    id object = [[[self class] alloc] init];
    for (ECLiteColoumn *col in coloumns)
    {
        id value = [self valueForKey:col.propertyName];
        value = [value copy];
        [object setValue:value forKey:col.propertyName];
    }
    return object;
}

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
+ (NSArray *)getAllColumnsFromClass:(Class)class
{
    NSMutableArray *cols = [NSMutableArray array];
    
    Class cl = class;
    
    unsigned int proCount = 0;
    objc_property_t *propertys = class_copyPropertyList(cl, &proCount);
    
    for (int i = 0; i < proCount; i++)
    {
        objc_property_t pro = propertys[i];
        
        NSString *name = [NSString stringWithUTF8String:property_getName(pro)];
        
        unsigned int attrsCount = 0;
        objc_property_attribute_t *attrList = property_copyAttributeList(pro, &attrsCount);
        
        NSString *propertyAttri = nil;
        const char *attriName = "T";
        for (int j = 0; j < attrsCount; j++)
        {
            objc_property_attribute_t proAttri = attrList[j];
            
            int count = strcmp(proAttri.name, attriName);
            if (count == 0)
            {
                propertyAttri = [NSString stringWithUTF8String:proAttri.value];
                break;
            }
        }
        
        ECLiteColoumn *col = [ECLiteColoumn initWithSqlColumnName:name sqlColumnType:0 propertyName:name];
        col.sqlColumnType = [ECLiteDB sqltypeFromPropertyAttri:propertyAttri inColoumn:col];
        
        [cols addObject:col];
    }
    return cols;
}

+ (SqlType)sqltypeFromPropertyAttri:(NSString *)attri inColoumn:(ECLiteColoumn *)col
{
    SqlType type = SqlTypeBlob;
    if ([attri containsString:@"@"])
    {
        //对象类型
        col.valueType = ValueTypeClass;
        
        NSInteger startIndex = @"T@\"".length -1;
        NSInteger endIndex = attri.length - 1;
    
        NSString *typeStr = [attri substringWithRange:NSMakeRange(startIndex, endIndex - startIndex)];
        
        if ([attri containsString:@"NSString"])
        {
            type = SqlTypeText;
            col.propertyType = @"NSString";
        }
        else
        {
            type = SqlTypeBlob;
            col.propertyType = typeStr;
        }
    }
    else if ([attri containsString:@"{"])
    {
        //结构体 暂不支持自定义结构体
        col.valueType = ValueTypeStruct;
        type = SqlTypeBlob;
        if ([attri containsString:@"CGRect"])
        {
            col.propertyType = @"CGRect";
        }
        else if ([attri containsString:@"CGSize"])
        {
            col.propertyType = @"CGSize";
        }
        else if ([attri containsString:@"CGPoint"])
        {
            col.propertyType = @"CGPoint";
        }
        else if ([attri containsString:@"CGAffineTransform"])
        {
            col.propertyType = @"CGAffineTransform";
        }
        else if ([attri containsString:@"CGVector"])
        {
            col.propertyType = @"CGVector";
        }
        else if ([attri containsString:@"CATransform3D"])
        {
            col.propertyType = @"CATransform3D";
        }
    }
    else
    {
        col.valueType = ValueTypeNum;
        if ([attri isEqualToString:@"q"])
        {
            type = SqlTypeInteger;
            col.propertyType = @"int";
        }
        else
        {
            type = SqlTypeReal;
            col.propertyType = @"double";
        }
    }
    
    return type;
}

+ (BOOL)createTable
{
    if (tableName.length <= 0)
    {
        tableName = [[self class] tableName];
        
        if (tableName.length == 0)
        {
            tableName = NSStringFromClass([self class]);
        }
        
        coloumns = [[self class] coloumns];
        
        if (coloumns.count == 0)
        {
            coloumns = [ECLiteDB getAllColumnsFromClass:[self class]];
        }
        
        primaryKey = [[self class] primaryKey];
        if (primaryKey.count == 0)
        {
            primaryKey = [ECLiteDB primaryKey];
        }
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
    
    
    NSString *createTableSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@)", tableName, table_pars];
    
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
        NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
        
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
            
            for (ECLiteColoumn *col in coloumns)
            {
                id value = dic[col.sqlColumnName];
                if (col.sqlColumnType == SqlTypeBlob)
                {
                    value = [NSKeyedUnarchiver unarchiveObjectWithData:value];
                }
                [object setValue:value forKey:col.propertyName];
            }
            
            ECLiteColoumn *col = primaryKey.lastObject;
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
