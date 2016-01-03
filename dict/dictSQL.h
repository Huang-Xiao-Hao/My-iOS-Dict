//
//  dictSQL.h
//  dict
//
//  Created by 黄小昊 on 15/12/19.
//  Copyright © 2015年 黄小昊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface dictSQL : NSObject{
    sqlite3 * sqlDB;
}

- (id)initWithDatabase:(NSString*)database;

- (NSMutableArray*)findWordListBy:(NSString*)word limit:(int)limit;

///获取单个词汇解释
- (NSDictionary*)getTheMean:(NSString*)indexid index:(int)iID;

///
- (NSData*)getTheSound:(NSString*)word withCode:(NSString*)code;

///获取详细列表
- (NSMutableArray*)findWordListBy:(NSString*)indexID limits:(int)limit;
@end
