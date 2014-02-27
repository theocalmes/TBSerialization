//
//  NSMutableDictionary+Setters.h
//  AllTrails
//
//  Created by Theodore Calmes on 5/30/13.
//  Copyright (c) 2013 AllTrails. All rights reserved.
//

@interface NSMutableDictionary (TBRecursiveKVC)

- (void)setValue:(id)value forNestedKey:(NSString *)nestedKey;

@end
