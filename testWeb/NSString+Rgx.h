//
//  NSString+Rgx.h
//  testWeb
//
//  Created by 李峰 on 2019/8/21.
//  Copyright © 2019 feng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Rgx)

- (NSString *) matchesWithPattern:(NSString *)pattern;
- (NSArray *)matchesWithPattern:(NSString *)pattern keys:(NSArray *)keys isContent:(BOOL)isc;

@end

NS_ASSUME_NONNULL_END
