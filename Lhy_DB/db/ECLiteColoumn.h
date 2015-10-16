//
//  ECLiteColoumn.h
//  ECLiteCore
//
//  Created by Apple on 15/6/3.
//  Copyright (c) 2015年 ecqq. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SqlType)
{
    SqlTypeText,
    SqlTypeInteger,
    SqlTypeReal,
    SqlTypeBlob,
};

typedef NS_ENUM(NSInteger, ValueType)
{
    ValueTypeClass,
    ValueTypeStruct,
    ValueTypeNum,
};

@interface ECLiteColoumn : NSObject
//保存到数据的  列名
@property(strong, nonatomic) NSString* sqlColumnName;
//保存到数据的类型
@property(assign, nonatomic) SqlType sqlColumnType;

//属性名
@property(strong, nonatomic) NSString* propertyName;

@property(strong, nonatomic) NSString* propertyType;
@property(assign, nonatomic) ValueType valueType;

//creating table's column
@property(assign, nonatomic) BOOL isUnique;
@property(assign, nonatomic) BOOL isNotNull;
@property(strong, nonatomic) NSString* defaultValue;
@property(strong, nonatomic) NSString* checkValue;
@property NSInteger length;

+ (instancetype)initWithSqlColumnName:(NSString *)sqlColumnName sqlColumnType:(SqlType)sqlColumnType propertyName:(NSString *)propertyName isUnique:(BOOL)isUnique isNotNull:(BOOL)isNotNull defaultValue:(NSString *)defaultValue checkValue:(NSString *)checkValue length:(NSInteger)length;
+ (instancetype)initWithSqlColumnName:(NSString *)sqlColumnName sqlColumnType:(SqlType)sqlColumnType propertyName:(NSString *)propertyName;

- (NSString *)sqlColumnTypeStr;
@end
