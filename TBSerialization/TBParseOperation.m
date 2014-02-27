//
//  TBParseOperation.m
//  TBPersistence
//
//  Created by Theodore Calmes on 11/13/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "TBParseOperation.h"

static NSString *const TBParseOperationDestinationClass = @"TBParseOperationDestinationClass";

@implementation TBParseOperation

- (id)initWithDestinationClass:(Class<TBSerializable>)destinationClass
{
    self = [super init];

    if (!self) {
        return nil;
    }

    _destinationClass = destinationClass;

    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:NSStringFromClass(self.destinationClass) forKey:TBParseOperationDestinationClass];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (!self) {
        return nil;
    }

    _destinationClass = NSClassFromString([aDecoder decodeObjectForKey:TBParseOperationDestinationClass]);

    return self;
}

@end
