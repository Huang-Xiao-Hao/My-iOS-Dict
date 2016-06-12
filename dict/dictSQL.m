//
//  dictSQL.m
//  dict
//
//  Created by 黄小昊 on 15/12/19.
//  Copyright © 2015年 黄小昊. All rights reserved.
//

#import "dictSQL.h"

@implementation dictSQL

//初始化数据库
- (id)initWithDatabase:(NSString*)database {
    NSString * url = [NSString stringWithFormat:@"%@/%@",[NSBundle mainBundle].bundlePath,database];
    if (sqlite3_open([url UTF8String], &sqlDB) != SQLITE_OK) {
        NSLog(@"数据库打开失败!");
    } else {
        NSLog(@"数据库%@打开成功!",database);
    }
    return [super init];
}

- (NSMutableArray*)findWordListBy:(NSString*)word limit:(int)limit{
    NSMutableArray* resultArray = [[NSMutableArray alloc] init];
    NSString * regex = @"[A-Za-z]";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([word length] > 0 && [predicate evaluateWithObject:[word substringToIndex:1]]){
        NSString* sql = [[NSString alloc]initWithFormat:@"select * from cald3hw_%@ where hw like '%@%%' limit %d"
                         ,[word substringToIndex:1]
                         ,word
                         ,limit];
        sqlite3_stmt* statement;
        if (sqlite3_prepare_v2(sqlDB, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
            NSMutableDictionary * tempDiction = [[NSMutableDictionary alloc]init];
            while (sqlite3_step(statement) == SQLITE_ROW) {
                //第一个值
                int indexid = sqlite3_column_int(statement, 0);
                [tempDiction setValue:@(indexid) forKey:@"indexid"];
                char * words = (char *)sqlite3_column_text(statement, 1);
                [tempDiction setValue:[NSString stringWithUTF8String:words] forKey:@"word"];
                char * wordclass = (char *)sqlite3_column_text(statement, 2);
                [tempDiction setValue:[NSString stringWithUTF8String:wordclass] forKey:@"wordclass"];
                int explanecount = sqlite3_column_int(statement, 3);
                [tempDiction setValue:@(explanecount) forKey:@"explanecount"];
                int nextflag = sqlite3_column_int(statement, 5);
                [tempDiction setValue:@(nextflag) forKey:@"nextflag"];
                [resultArray addObject:[tempDiction copy]];
                [tempDiction removeAllObjects];
            }
        }else{
            NSLog(@"%d /n %@",sqlite3_prepare_v2(sqlDB, [sql UTF8String], -1, &statement, nil),sql);
        }
    }
    return resultArray;
}

- (NSMutableArray*)findWordListBy:(NSString*)indexID limits:(int)limit{
    NSMutableArray* resultArray = [[NSMutableArray alloc] init];
    NSString* sql;
    sqlite3_stmt* statement;
    int limits = 0;
    //处理多项解释
    for (int indexi = 1;  indexi <= limit; indexi++) {
        sql = [[NSString alloc]initWithFormat:@"select * from gw where indexid == '%@%d'",indexID,indexi];
        if (sqlite3_prepare_v2(sqlDB, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
            NSMutableDictionary * tempDiction = [[NSMutableDictionary alloc]init];
            while (sqlite3_step(statement) == SQLITE_ROW) {
                char * wordclass = (char *)sqlite3_column_text(statement, 0);
                [tempDiction setValue:[NSString stringWithUTF8String:wordclass] forKey:@"wordclass"];
                char * wordmean = (char *)sqlite3_column_text(statement, 2);
                [tempDiction setValue:[NSString stringWithUTF8String:wordmean] forKey:@"wordmean"];
                int indexid = sqlite3_column_int(statement, 3);
                [tempDiction setValue:@(indexid) forKey:@"indexid"];
                char * phrasestr = (char *)sqlite3_column_text(statement, 4);
                [tempDiction setValue:[NSString stringWithUTF8String:phrasestr] forKey:@"phrasestr"];
                int tpcount = sqlite3_column_int(statement, 5);
                [tempDiction setValue:@(tpcount) forKey:@"tpcount"];
                char * phraseindex = (char *)sqlite3_column_text(statement, 6);
                [tempDiction setValue:[NSString stringWithUTF8String:phraseindex] forKey:@"phraseids"];
                [resultArray addObject:[tempDiction copy]];
                [tempDiction removeAllObjects];
                limits = limits + tpcount;
            }
            if (limits == limit) {
                break;
            }
        }else{
            NSLog(@"%d /n %@",sqlite3_prepare_v2(sqlDB, [sql UTF8String], -1, &statement, nil),sql);
            break;
        }
    }
    return resultArray;
}

- (NSDictionary*)getTheMean:(NSString*)indexid index:(int)iID{
    NSMutableDictionary* resultDict = [[NSMutableDictionary alloc] init];
    NSString* sql;
    if (iID == -1) {//单义词，无需跳转
        sql = [[NSString alloc]initWithFormat:@"select * from hwpage where indexid == '%@%d'",indexid,1];
    }else{
        sql = [[NSString alloc]initWithFormat:@"select * from hwpage where indexid == '%@'",indexid];
    }
    sqlite3_stmt* statement;
    if (sqlite3_prepare_v2(sqlDB, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int indexid = sqlite3_column_int(statement, 0);
            [resultDict setValue:@(indexid) forKey:@"indexid"];
            char * mean = (char *)sqlite3_column_text(statement, 1);
            [resultDict setValue:[NSString stringWithUTF8String:mean] forKey:@"mean"];
            char * uk = (char *)sqlite3_column_text(statement, 2);
            [resultDict setValue:[NSString stringWithUTF8String:uk] forKey:@"uk"];
            char * us = (char *)sqlite3_column_text(statement, 3);
            [resultDict setValue:[NSString stringWithUTF8String:us] forKey:@"us"];
        }
    }else{
        NSLog(@"%d /n %@",sqlite3_prepare_v2(sqlDB, [sql UTF8String], -1, &statement, nil),sql);
        return @{@"errcode" : @"500"};
    }
    return resultDict;
}

- (NSData*)getTheSound:(NSString*)word withCode:(NSString*)code {
    NSString* sql = [[NSString alloc]initWithFormat:@"select * from v where f == '%@%@'",word,code];
    sqlite3_stmt* statement;
    NSData * sound;
    if (sqlite3_prepare_v2(sqlDB, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int length=sqlite3_column_bytes(statement,1);//获取二进制数据的长度
            sound = [NSData dataWithBytes:sqlite3_column_blob(statement, 1) length:length]; //将二进制数据转换位NSData对象
        }
    }else{
        NSLog(@"%d /n %@",sqlite3_prepare_v2(sqlDB, [sql UTF8String], -1, &statement, nil),sql);
    }
//    NSLog(@"length : %d\n%@",[sound length],sound);
    return sound;
}

@end