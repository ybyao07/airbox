//
//  NSMutableDictionary+Utility.h
//  QunariPhone
//
//  Created by Neo on 3/8/13.
//  Copyright (c) 2013 Qunar.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Utility)

// 设置Key/Value
- (void)setObjectSafe:(id)anObject forKey:(id < NSCopying >)aKey;

@end
