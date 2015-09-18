//
//  ECLiteDB.h
//  DBTest
//
//  Created by Apple on 15/6/4.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECLiteColoumn.h"
#import "ECLiteDatabase.h"

@interface ECLiteDB : NSObject

@property (readonly, nonatomic) NSInteger rowID;//默认加上的自增id

#pragma mark - 由子类实现

/**
 *  表名
 */
+ (NSString *)tableName;

/**
 *  主键之外的列(由ECLiteColoumn组成)
 */
+ (NSArray *)coloumns;


#pragma mark - 基类方法(禁止重写)
/**
 *  建表
 *  @return 建表是否成功
 */
+ (BOOL)createTable;

/**
 *  批量插入
 *
 *  @param data 数据
 *
 */
+ (void)insertAll:(NSArray *)data;

/**
 *  插入数据
 *
 *  @return 数据插入数据库后的唯一id
 */
- (BOOL)insert;

/**
 *  删除数据(由于存在联合主键，无法单个给值，传递对象，在内部根据kvo由主键去取值)
 *
 *  @return 操作的结果
 */
- (BOOL)remove;

/**
 *  更新数据库(主键不会更新,根据主键来更新)
 *
 *  @return 操作结果
 */
- (BOOL)update;

/**
 *  查询
 *
 *  @param sql 查询语句(where后的语句)
 *
 *  @return 查询结果
 */
+ (NSArray *)dbWithSqlWhere:(NSString *)sql;

@end
