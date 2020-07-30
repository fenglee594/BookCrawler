//
//  Book.m
//  testWeb
//
//  Created by 李峰 on 2019/8/21.
//  Copyright © 2019 feng. All rights reserved.
//

#import "Book.h"
#import <MJExtension.h>

@implementation Book

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"desc" : @"description"
             };
}
@end
