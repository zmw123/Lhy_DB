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

@interface ECLiteColoumn : NSObject
//保存到数据的  列名
@property(copy,nonatomic)NSString* sqlColumnName;
//保存到数据的类型
@property(nonatomic)SqlType sqlColumnType;

//属性名
@property(copy,nonatomic)NSString* propertyName;

//creating table's column
@property BOOL isUnique;
@property BOOL isNotNull;
@property(copy,nonatomic) NSString* defaultValue;
@property(copy,nonatomic) NSString* checkValue;
@property NSInteger length;

+ (instancetype)initWithSqlColumnName:(NSString *)sqlColumnName sqlColumnType:(SqlType)sqlColumnType propertyName:(NSString *)propertyName isUnique:(BOOL)isUnique isNotNull:(BOOL)isNotNull defaultValue:(NSString *)defaultValue checkValue:(NSString *)checkValue length:(NSInteger)length;
+ (instancetype)initWithSqlColumnName:(NSString *)sqlColumnName sqlColumnType:(SqlType)sqlColumnType propertyName:(NSString *)propertyName;

- (NSString *)sqlColumnTypeStr;
@end
