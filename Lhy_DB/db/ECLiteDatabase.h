//
//  Database.h
//  ECLite
//
//  Created by Apple on 15/1/18.
//  Copyright (c) 2015年 ec. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabaseQueue;

#define CoreUserID   [ECLiteDatabase instance].userID


@interface ECLiteDatabase : NSObject

@property (strong, nonatomic) FMDatabaseQueue *dbQueue;
@property (strong, nonatomic) NSString *dbPath;
@property (nonatomic) NSInteger  userID;

+ (ECLiteDatabase *)instance;

@end
