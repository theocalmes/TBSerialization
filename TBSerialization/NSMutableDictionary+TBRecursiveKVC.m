//
//  NSMutableDictionary+Setters.m
//  AllTrails
//
//  Created by Theodore Calmes on 5/30/13.
//  Copyright (c) 2013 AllTrails. All rights reserved.
//

#import "NSMutableDictionary+ATRecursiveKVC.h"

@implementation NSMutableDictionary (TBRecursiveKVC)

- (void)setValue:(id)value forNestedKey:(NSString *)nestedKey
{
    NSMutableArray *keys = [nestedKey componentsSeparatedByString:@"."].mutableCopy;

    if ([keys count] == 1) {
        [self setValue:value forKey:nestedKey];
        return;
    }

    NSString *currentKey = keys[0];
    
    if (![self.allKeys containsObject:currentKey]) {
        NSMutableDictionary *dictionaryForCurrentKey = [NSMutableDictionary new];
        [self setValue:dictionaryForCurrentKey forKey:currentKey];
        [self setValue:value forNestedKey:nestedKey];
    } else {
        [keys removeObjectAtIndex:0];
        [self[currentKey] setValue:value forNestedKey:[keys componentsJoinedByString:@"."]];
    }
}

@end
