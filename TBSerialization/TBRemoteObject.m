//
//  TBJSONObject.m
//  TBPersistence
//
//  Created by Theodore Calmes on 11/6/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "TBRemoteObject.h"
#import "TBSerialization.h"

@interface TBRemoteObject ()

@property (assign, nonatomic, readwrite) Class<TBSerializable> localObjectClass;
@property (strong, nonatomic, readwrite) NSDictionary *remoteObjectDictionary;
@property (strong, nonatomic) TBPropertyMap *map;

@end

@implementation TBRemoteObject

- (id)initWithClass:(Class<TBSerializable>)localObjectClass dictionary:(NSDictionary *)remoteObjectDictionary
{
    self = [super init];
    if (self) {
        _localObjectClass = localObjectClass;
        _remoteObjectDictionary = remoteObjectDictionary;
        _map = [localObjectClass localToRemoteMap];
    }

    return self;
}

- (NSString *)jsonKeyPathForLocalKey:(NSString *)localKey
{
    if (!self.map || !self.map.toObjectMap[localKey]) {
        return localKey;
    }

    return self.map.toObjectMap[localKey];
}

- (id)jsonValueForLocalKey:(NSString *)localKey
{
    return [self.remoteObjectDictionary valueForKeyPath:[self jsonKeyPathForLocalKey:localKey]];
}

- (NSString *)jsonKeyPathForProperty:(NSPropertyDescription *)property
{
    NSString *localKey = property.name;
    return [self jsonKeyPathForLocalKey:localKey];
}

- (id)jsonValueForProperty:(NSPropertyDescription *)property
{
    return [self.remoteObjectDictionary valueForKeyPath:[self jsonKeyPathForProperty:property]];
}

#pragma mark - To JSON

- (BOOL)shouldConvertValueForLocalKeyToJSON:(NSString *)localKey
{
    return ![self.map.excludedSerializationKeys containsObject:localKey];
}

- (BOOL)shouldConvertValueForPropertyToJSON:(NSPropertyDescription *)property
{
    return ![self.map.excludedSerializationKeys containsObject:property.name];
}

#pragma mark - TBUniquelySerializable

- (BOOL)hasUniqueIdentifier
{
    Class localObjectClass = (Class<TBUniquelySerializable>)self.localObjectClass;
    return [localObjectClass conformsToProtocol:@protocol(TBUniquelySerializable)];
}

- (NSString *)localKeyPathForUniqueIdentifier
{
    if (![self hasUniqueIdentifier]) {
        return nil;
    }

    Class<TBUniquelySerializable> localObjectClass = (Class<TBUniquelySerializable>)self.localObjectClass;
    return [localObjectClass uniqueIdentifierLocalKey];
}

- (NSNumber *)jsonValueForUniqueIdentifier
{
    if (![self hasUniqueIdentifier]) {
        return nil;
    }

    Class<TBUniquelySerializable> localObjectClass = (Class<TBUniquelySerializable>)self.localObjectClass;
    return [localObjectClass uniqueIdentifierFromRemoteObject:self];
}

@end
