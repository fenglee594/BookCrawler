//
//  Storage.m
//  testWeb
//
//  Created by 李峰 on 2019/8/29.
//  Copyright © 2019 feng. All rights reserved.
//

#import "Storage.h"
#import <MJExtension.h>
#import "Book.h"

@implementation Storage

static Storage *sharedInstance = nil;

+ (Storage *) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Storage alloc] init];
    });
    return sharedInstance;
}


+ (void) saveBook:(Book *)book
{
//    NSString *key = [NSString stringWithFormat:@"%@_%@",book.title, book.url];
//    SMUserDefaultSet(key, [book mj_keyValues]);
}




@end
