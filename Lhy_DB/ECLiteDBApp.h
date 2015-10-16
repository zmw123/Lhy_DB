//
//  ECLiteDBApp.h
//  ECLiteDatabase
//
//  Created by qinwenzhou on 15/1/21.
//  Copyright (c) 2015年 ec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECLiteDB.h"
#import <UIKit/UIKit.h>

// 字段
#define app_id              @"_id"
#define app_firstStart      @"_firstStart"
#define app_lastUserID      @"_lastUserID"
#define app_appVersion      @"_appVersion"
#define app_appStoreVersion @"_appStoreVersion"
#define app_dbVersion       @"_dbVersion"

@interface ECLiteDBApp : ECLiteDB

//@property (nonatomic) NSInteger firstStart; // 第一次启动
//@property (nonatomic) NSInteger lastUserID; // 最新用户ID
//@property (nonatomic) NSInteger appVerson; // 当前版本
//@property (nonatomic) NSString *appStoreVersion;//appStore版本
//@property (nonatomic) NSInteger  dbVersion; //数据版本

@property (strong, nonatomic) NSString *str;
@property (strong, nonatomic) NSArray *array;
@property (strong, nonatomic) NSDictionary *dic;
@property (strong, nonatomic) NSNumber *number;
@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) NSMutableData *mutableData;
@property (assign, nonatomic) NSInteger integer;
@property (assign, nonatomic) CGPoint point;
@property (assign, nonatomic) CGRect rect;
@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) double dou;
@property (assign, nonatomic) float flo;
@property (assign, nonatomic) CGAffineTransform transForm;

@end
