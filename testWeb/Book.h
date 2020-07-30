//
//  Book.h
//  testWeb
//
//  Created by 李峰 on 2019/8/21.
//  Copyright © 2019 feng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



@interface Book : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *autor;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *desc;
@end

@interface BookCategory : NSObject
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, strong) NSArray <Book*> *books;
@end

NS_ASSUME_NONNULL_END
