//
//  Storage.h
//  testWeb
//
//  Created by 李峰 on 2019/8/29.
//  Copyright © 2019 feng. All rights reserved.
//

#import <Foundation/Foundation.h>



#define SMUserDefault               [NSUserDefaults standardUserDefaults]
#define SMUserDefaultSet(key,value) [SMUserDefault setObject:value forKey:key];[SMUserDefault synchronize]
#define SMUserDefaultGet(key)       [SMUserDefault objectForKey:key]

NS_ASSUME_NONNULL_BEGIN

@interface Storage : NSObject

@end

NS_ASSUME_NONNULL_END
