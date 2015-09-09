//
//  NSMutableDictionary+Utility.m
//  QunariPhone
//
//  Created by Neo on 3/8/13.
//  Copyright (c) 2013 Qunar.com. All rights reserved.
//

#import "NSMutableDictionary+Utility.h"

@implementation NSMutableDictionary (Utility)

// 设置Key/Value
- (void)setObjectSafe:(id)anObject forKey:(id < NSCopying >)aKey
{
	if(anObject != nil)
	{
		[self setObject:anObject forKey:aKey];
	}
    else
    {
        if ([self objectForKey:aKey])
        {
            [self removeObjectForKey:aKey];
        }
    }
}

@end
