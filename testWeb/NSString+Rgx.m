//
//  NSString+Rgx.m
//  testWeb
//
//  Created by 李峰 on 2019/8/21.
//  Copyright © 2019 feng. All rights reserved.
//

#import "NSString+Rgx.h"

@implementation NSString (Rgx)



//第一次匹配
- (NSString *) matchesWithPattern:(NSString *)pattern
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                             error:&error];
    
    if (error) {
        NSLog(@"匹配方案错误:%@", error.localizedDescription);
        return nil;
    }
    
    NSTextCheckingResult *result = [regex firstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
    
    if (result) {
        NSRange range = [result rangeAtIndex:0];
        return [self substringWithRange:range];
    } else {
        NSLog(@"没有找到匹配内容 %@", pattern);
        return nil;
    }
    
}


- (NSArray *)arrayMatchesWithPattern:(NSString *)pattern
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                             error:&error];
    
    if (error) {
        NSLog(@"匹配方案错误:%@", error.localizedDescription);
        return nil;
    }
    
    return [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
}



/*
 isChapter:用来处理标题章节
 isContent:用来处理正文内容中的各种转义字符
 */
- (NSArray *)matchesWithPattern:(NSString *)pattern keys:(NSArray *)keys isContent:(BOOL)isc
{
    NSArray *array = [self arrayMatchesWithPattern:pattern];
    
    if (array.count == 0) return nil;
    
    NSMutableArray *arrayM = [NSMutableArray array];
    
    for (NSTextCheckingResult *result in array) {
        NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
        
        for (int i = 0; i < keys.count; i++) {
            NSRange range = [result rangeAtIndex:(i + 1)];
            
            
            NSString *content = isc ? [self dealWithContent:[self substringWithRange:range]] : [self substringWithRange:range];
            
            [dictM setObject:content forKey:keys[i]];
        }
        [arrayM addObject:dictM];
    }
    
    return [arrayM copy];
}



- (NSString *)dealWithContent:(NSString *)content
{
    /*
     &amp;ldquo;表示中文输入法下的双引号
     &amp;quot; 表示英文输入法下的双引号
     &amp;lt;表示小于号
     &amp;gt;表示大于号
     &amp;nbsp;表示空格
     
     其中&amp;在浏览器具体显示是就是&符号，不行你通过CSDN编辑器编辑发布一下。因此本质上上述东东又可以进一步编译成
     
     &ldquo;表示中文输入法下的双引号
     &quot; 表示英文输入法下的双引号
     &lt;表示小于号
     &gt;表示大于号
     &nbsp;表示空格
     */
    return [[[[[[[[[content stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""] stringByReplacingOccurrencesOfString:@"&ldquo;" withString:@"“"] stringByReplacingOccurrencesOfString:@"&rdquo;" withString:@"”"] stringByReplacingOccurrencesOfString:@"&hellip;" withString:@"..."] stringByReplacingOccurrencesOfString:@"&mdash;" withString:@"-"] stringByReplacingOccurrencesOfString:@"&lsquo;" withString:@"‘"] stringByReplacingOccurrencesOfString:@"&rsquo;" withString:@"’"] stringByReplacingOccurrencesOfString:@"&#8226;" withString:@"·"] stringByReplacingOccurrencesOfString:@"&#039;" withString:@""];
}

@end
