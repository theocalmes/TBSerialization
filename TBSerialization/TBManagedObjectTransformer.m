//
//  TBManagedObjectTransformer.m
//  TBPersistence
//
//  Created by Theodore Calmes on 11/8/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "TBManagedObjectTransformer.h"
#import "TBValueTransformations.h"
#import "TBRemoteObjectTraversal.h"
#import "TBRemoteIdentifierToManagedObjectIDCache.h"
#import "NSMutableDictionary+TBRecursiveKVC.h"

@interface TBManagedObjectTransformer ()
@property (strong, nonatomic) TBRemoteIdentifierToManagedObjectIDCache *cache;
@end

@implementation TBManagedObjectTransformer

- (id)initWithRemoteIDCache:(TBRemoteIdentifierToManagedObjectIDCache *)cache
{
    self = [super init];
    if (self) {
        _cache = cache;
    }

    return self;
}

- (NSManagedObject *)managedObjectForRemoteObject:(TBRemoteObject *)remoteObject
{
    NSManagedObject *managedObject;

    BOOL shouldUpdateManagedObject = YES;

    if ([remoteObject hasUniqueIdentifier]) {
        managedObject = [self.cache managedObjectForRemoteObject:remoteObject];

        if ([managedObject respondsToSelector:@selector(shouldSerializeWithRemoteObject:)]) {
            shouldUpdateManagedObject = [(NSManagedObject <TBUniquelySerializable> *)managedObject shouldSerializeWithRemoteObject:remoteObject];
        }
    }

    if (!managedObject) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(remoteObject.localObjectClass) inManagedObjectContext:self.cache.context];
        managedObject = [[NSClassFromString(entity.name) alloc] initWithEntity:entity insertIntoManagedObjectContext:self.cache.context];

        if ([remoteObject hasUniqueIdentifier]) {
            [self.cache addManagedObject:managedObject withRemoteObject:remoteObject];
        }
    }

    if (shouldUpdateManagedObject) {
        [self updateManagedObject:managedObject withRemoteObject:remoteObject];
    }

    return managedObject;
}

- (void)updateManagedObject:(NSManagedObject<TBSerializable> *)managedObject withRemoteObject:(TBRemoteObject *)remoteObject
{
    NSDictionary *attributes = managedObject.entity.attributesByName;
    for (NSAttributeDescription *attribute in attributes.allValues) {

        if (!attribute.isTransient && attribute.attributeType == NSUndefinedAttributeType) {
            continue;
        }

        id jsonValue = [remoteObject jsonValueForProperty:attribute];

        if (!jsonValue) {
            continue;
        }

        id transformedValue = [TBValueTransformations transformJSONValue:jsonValue toAttributeType:attribute.attributeType];

        if (!transformedValue) {
            continue;
        }

        [managedObject setValue:transformedValue forKey:attribute.name];
    }

    __weak typeof(self) weakSelf = self;
    [TBRemoteObjectTraversal traverseRelationshipsForEntity:managedObject.entity withDictionary:remoteObject.remoteObjectDictionary traversalBlock:^(NSRelationshipDescription *relationship, NSArray *remoteObjects) {

        NSMutableArray *managedObjects = [[NSMutableArray alloc] initWithCapacity:remoteObjects.count];

        for (TBRemoteObject *object in remoteObjects) {
            [managedObjects addObject:[weakSelf managedObjectForRemoteObject:object]];
        }
        
        if (managedObjects.count == 0) {
            return;
        }

        if ([relationship isToMany]) {
            [managedObject setValue:[NSSet setWithArray:managedObjects] forKey:relationship.name];
        } else {
            [managedObject setValue:[managedObjects lastObject] forKey:relationship.name];
        }
    }];

    if ([managedObject respondsToSelector:@selector(didUpdateWithRemoteObject:)]) {
        [managedObject didUpdateWithRemoteObject:remoteObject];
    }
}

#pragma mark - Serialization

+ (NSDictionary *)JSONDictionaryForManagedObject:(NSManagedObject<TBSerializable> *)managedObject
{
    return [self JSONDictionaryForManagedObject:managedObject excludingRelationship:nil];
}

+ (NSDictionary *)JSONDictionaryForManagedObject:(NSManagedObject<TBSerializable> *)managedObject excludingRelationship:(NSRelationshipDescription *)excludedRelationship
{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    NSDictionary *attributes = managedObject.entity.attributesByName;

    if ([attributes.allKeys count] == 0) {
        return nil;
    }

    TBRemoteObject *remoteObject = [[TBRemoteObject alloc] initWithClass:[managedObject class] dictionary:nil];

    for (NSAttributeDescription *attribute in attributes.allValues) {
        if (![remoteObject shouldConvertValueForPropertyToJSON:attribute]) {
            continue;
        }

        id localValue = [managedObject valueForKey:attribute.name];

        if ([localValue isKindOfClass:[NSDate class]]) {
            localValue = [TBValueTransformations stringFromDate:localValue];
        }
        if ([localValue isKindOfClass:[NSNumber class]]) {
            if ([localValue integerValue] == 0) {
                continue;
            }
        }

        if (!localValue) {
            continue;
        }

        NSString *jsonKeyPath = [remoteObject jsonKeyPathForProperty:attribute];

        if (!jsonKeyPath) {
            continue;
        }

        [json setValue:localValue forNestedKey:jsonKeyPath];
    }

    NSDictionary *relationships = [[managedObject entity] relationshipsByName];

    for (NSRelationshipDescription *relationship in relationships.allValues) {

        if ([relationship isEqual:excludedRelationship]) {
            continue;
        }

        if (![remoteObject shouldConvertValueForPropertyToJSON:relationship]) {
            continue;
        }

        id value = nil;

        if ([relationship isToMany]) {
            NSMutableArray *filteredObjects = [[NSMutableArray alloc] init];
            NSArray *allRelatedObjects = [[managedObject valueForKey:relationship.name] allObjects];

            for (NSManagedObject<TBSerializable> *object in allRelatedObjects) {
                [filteredObjects addObject:[self JSONDictionaryForManagedObject:object excludingRelationship:relationship.inverseRelationship]];
            }

            if (filteredObjects.count != 0) {
                value = [filteredObjects copy];
            }
        } else {
            NSDictionary *dictionary = [self JSONDictionaryForManagedObject:[managedObject valueForKey:relationship.name] excludingRelationship:relationship.inverseRelationship];
            if (dictionary && [[dictionary allKeys] count] != 0) {
                value = dictionary;
            }
        }

        if (!value) {
            continue;
        }

        NSString *jsonKeyPath = [remoteObject jsonKeyPathForProperty:relationship];

        if (!jsonKeyPath) {
            continue;
        }
        
        [json setValue:value forNestedKey:jsonKeyPath];
    }
    
    return [json copy];
}

@end
