//
//  ViewController.m
//  testWeb
//
//  Created by 李峰 on 2019/8/21.
//  Copyright © 2019 feng. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "NSString+Rgx.h"
#import <MJExtension.h>
#import "Book.h"
#import "ViewControllerB.h"
#import <WebKit/WebKit.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *string = [self htmlWithUrlString:@"http://www.qihuan.net.cn/book-east.html"];
    NSLog(@"%@",string);
    
    
    //匹配书籍
    NSString *aa = [string matchesWithPattern:@"<ul class=\"co3\">(.*?)</ul>"];

    NSArray *array = [aa matchesWithPattern:@"<li><a href=\"(.*?)\" title=\"(.*?)\">(.*?)</a><span>" keys:@[@"url",@"autor",@"title"] isContent:NO];
//    <a href="/book/jiuzhou_piaomiaolu_chenyuezhizheng.html" title="九州·缥缈录Ⅳ·辰月之征 - 江南">九州·缥缈录Ⅳ·辰月之征</a>
//    <a href="/book/Baccano.html" title="永生之酒 - 成田良悟">永生之酒</a>
//    <a href="/book/Children_of_the_Rune.html" title="符文之子 - 全民熙">符文之子</a>
//    NSArray *array = @[@{
//                           @"url"   :  @"/book/Children_of_the_Rune.html",
//                           @"autor" :   @"符文之子 - 全民熙",
//                           @"title" :   @"符文之子",
//                           }];
    
    NSMutableArray *books = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dic in array) {
        if (dic) {
            NSMutableDictionary *book = [NSMutableDictionary dictionary];
            [book setObject:[NSString stringWithFormat:@"http://www.qihuan.net.cn%@",dic[@"url"]] forKey:@"url"];
            NSRange range = [dic[@"autor"] rangeOfString:@"-"];
            NSString *autor = [dic[@"autor"] substringFromIndex:range.location + 2];
            [book setObject:autor forKey:@"autor"];
            [book setObject:dic[@"title"] forKey:@"name"];
            [book setObject:@"11" forKey:@"description"];
            [books addObject:book];
        }
        
    }
    
    
    
    books = [Book mj_objectArrayWithKeyValuesArray:books];
    
    
    //获取Document文件
    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"%@",docsdir);
    NSString * rarFilePath = [docsdir stringByAppendingPathComponent:@"东方奇幻"];//将需要创建的串拼接到后面
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    BOOL existed = [fileManager fileExistsAtPath:rarFilePath isDirectory:&isDir];
    if (existed == NO) {//如果文件夹不存在
        [fileManager createDirectoryAtPath:rarFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    
    for (int i = 0; i < books.count; i ++) {
        
        NSString *string = [self htmlWithUrlString:((Book *)books[i]).url];
        NSLog(@"---:%@",string);
        
        //匹配简介
        NSString *description = [string matchesWithPattern:@"<p>(.*?)</p>"];
        
        NSLog(@"%@",description);
        description = [[description substringFromIndex:3] substringToIndex:description.length - 7];
        
        //将简介存入字典
        ((Book *)books[i]).desc = description;
        
        
        //匹配小说章节目录
        NSString *chapterString = [string matchesWithPattern:@"<dl>(.*)</dl>"];
        
//        NSLog(@"--chapterString:%@",chapterString);
        
        NSArray *chapterArray = [chapterString matchesWithPattern:@"<dd><a href=\"(.*?)\">(.*?)</a></dd>" keys:@[@"url",@"chapterName"] isContent:NO];
        
        NSLog(@"--chapterString:%@",chapterString);
        
        
        
        //写入章节内容
//        for (NSDictionary *chapter in chapterArray) {
            for (int j=0 ; j<chapterArray.count; j++){
            NSString *content = [self htmlWithUrlString:[NSString stringWithFormat:@"http://www.qihuan.net.cn%@",chapterArray[j][@"url"]]];
            
            NSLog(@"content:%@",content);
            
            
//            NSMutableArray *contentMarray = [NSMutableArray arrayWithCapacity:0];
            
            //正文中的章节标题
            NSArray *array1 = [content matchesWithPattern:@"<h1>(.*)</h1>" keys:@[@"chaptername"] isContent:NO];
//            [contentMarray addObject:array1[0][@"content"]];
                NSString *chapterName = array1[0][@"chaptername"];
                if (!([chapterName containsString:@"第"] && [chapterName containsString:@"章"])) {
                    chapterName = [NSString stringWithFormat:@"|| %@",chapterName];
                }
            
            [self writeToFile:((Book *)books[i]).name WithTxt:chapterName];
            
            //匹配章节正文内容
            NSArray *array2 = [content matchesWithPattern:@"<p>(.*?)</p>" keys:@[@"content"] isContent:YES];
            
            NSString *chapterContent = [NSString string];
            for (int i = 0; i < array2.count; i ++) {
                chapterContent = [NSString stringWithFormat:@"%@\n%@",chapterContent,array2[i][@"content"]];
            }
            
            [self writeToFile:((Book *)books[i]).name WithTxt:chapterContent];
            
        }
        
        if (i == books.count - 1) {
            NSString *fpath = [rarFilePath stringByAppendingPathComponent:@"books.json"];
            if (![fileManager fileExistsAtPath:fpath]) {
                NSArray * jsonArray = [Book mj_keyValuesArrayWithObjectArray:books];
                NSData * data = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                [jsonString writeToFile:fpath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
            
            NSLog(@"%@",NSHomeDirectory());
        }
        
        
    }
    
    
}


//不论是创建还是写入只需调用此段代码即可 如果文件未创建 会进行创建操作
- (void)writeToFile:(NSString *)bookName WithTxt:(NSString *)string{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @synchronized (self) {
            //获取沙盒路径
            NSArray *paths  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
            //获取文件路径
            NSString *theFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"东方奇幻"];
            theFilePath = [theFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",bookName]];
            //创建文件管理器
            NSFileManager *fileManager = [NSFileManager defaultManager];
            //如果文件不存在 创建文件
            if(![fileManager fileExistsAtPath:theFilePath]){
                NSString *str = @"";
                [str writeToFile:theFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
            NSLog(@"所写内容=%@",string);
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:theFilePath];
            [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
            NSData* stringData  = [[NSString stringWithFormat:@"%@\n",string] dataUsingEncoding:NSUTF8StringEncoding];
            [fileHandle writeData:stringData]; //追加写入数据
            [fileHandle closeFile];
        }
    });
}

- (NSString *)htmlWithUrlString:(NSString *)urlString {
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSError *error = nil;
    
    if (error) {
        NSLog(@"%@",error.localizedDescription);
        return nil;
    }
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:&error];
    NSString *backStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return backStr;
}


//- (NSString *) matchWithPattern:(NSString *)pattern formOrigin:(NSString *)origin
//{
//    NSError *error = nil;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
//                                                                           options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
//                                                                             error:&error];
//
//    if (error) {
//        NSLog(@"匹配方案错误:%@", error.localizedDescription);
//        return nil;
//    }
//
//    NSTextCheckingResult *result = [regex firstMatchInString:origin options:0 range:NSMakeRange(0, origin.length)];
//
//    if (result) {
//        NSRange range = [result rangeAtIndex:0];
//        return [origin substringWithRange:range];
//    } else {
//        NSLog(@"没有找到匹配内容 %@", pattern);
//        return nil;
//    }
//
//}


//- (NSArray *)matchesWithPattern:(NSString *)pattern OriginString:(NSString *)org
//{
//    NSError *error = nil;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
//                                                                           options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
//                                                                             error:&error];
//
//    if (error) {
//        NSLog(@"匹配方案错误:%@", error.localizedDescription);
//        return nil;
//    }
//
//    return [regex matchesInString:org options:0 range:NSMakeRange(0, org.length)];
//}


- (void) tiaozhuan
{
    [self presentViewController:[ViewControllerB new] animated:YES completion:nil];
}

- (void)dealloc
{
    NSLog(@"%@__%s",NSStringFromClass([self class]), __func__);
}





@end
