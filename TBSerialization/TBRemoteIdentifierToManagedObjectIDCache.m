//
//  TBRemoteIdentifierToManagedObjectIDCache.m
//  TBPersistence
//
//  Created by Theodore Calmes on 11/13/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "TBRemoteIdentifierToManagedObjectIDCache.h"
#import "TBRemoteObjectTraversal.h"

void TBAppendRemoteObjectIdentifiersOfClassToRemoteIdentifierMap(NSArray *remoteIDs, NSString *classNameKey, NSMutableDictionary *remoteIdentifierMap)
{
    NSMutableSet *classRemoteIDSet = remoteIdentifierMap[classNameKey];
    if (!classRemoteIDSet) {
        classRemoteIDSet = [NSMutableSet new];
    }

    [classRemoteIDSet addObjectsFromArray:remoteIDs];
    remoteIdentifierMap[classNameKey] = classRemoteIDSet;
}

NSString *TBCacheKeyForRemoteIdentifierOfClass(NSNumber *remoteIdentifier, NSString *className)
{
    return [NSString stringWithFormat:@"%@%@", className, remoteIdentifier];
}

@interface TBRemoteIdentifierToManagedObjectIDCache ()
@property (strong, nonatomic) NSMutableDictionary *remoteIDToManagedObjectCache;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *context;
@end

@implementation TBRemoteIdentifierToManagedObjectIDCache

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        _context = context;
        _remoteIDToManagedObjectCache = [NSMutableDictionary new];
    }

    return self;
}

- (NSManagedObject *)managedObjectForRemoteObject:(TBRemoteObject *)remoteObject
{
    NSString *key = TBCacheKeyForRemoteIdentifierOfClass([remoteObject jsonValueForUniqueIdentifier], NSStringFromClass(remoteObject.localObjectClass));
    NSManagedObjectID *existingObjectID = self.remoteIDToManagedObjectCache[key];

    if (!existingObjectID) {
        return nil;
    }

    __block NSManagedObject *existingObject = nil;

    [self.context performBlockAndWait:^{
        existingObject = [self.context existingObjectWithID:existingObjectID error:nil];
    }];

    return existingObject;
}

- (void)updateCacheWithRemoteObjects:(NSArray *)remoteObjects
{
    NSMutableDictionary *remoteIdentifierMap = [NSMutableDictionary new];
    for (TBRemoteObject *remoteObject in remoteObjects) {
        [self gatherAllUniqueIdentifiersFromRemoteObject:remoteObject appendingToDictionary:remoteIdentifierMap];
    }

    for (NSString *className in remoteIdentifierMap) {
        [self updateManagedObjectToRemoteIDCacheForClass:NSClassFromString(className) withRemoteIdentifiers:remoteIdentifierMap[className]];
    }
}

- (void)clearCache
{
    [self.remoteIDToManagedObjectCache removeAllObjects];
}

#pragma mark - Private

- (void)gatherAllUniqueIdentifiersFromRemoteObject:(TBRemoteObject *)object appendingToDictionary:(NSMutableDictionary *)remoteIdentifierMap
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(object.localObjectClass) inManagedObjectContext:self.context];

    id objectRemoteID = [object jsonValueForUniqueIdentifier];
    TBAppendRemoteObjectIdentifiersOfClassToRemoteIdentifierMap(@[objectRemoteID], entity.name, remoteIdentifierMap);

    [TBRemoteObjectTraversal traverseRelationshipsForEntity:entity withDictionary:object.remoteObjectDictionary traversalBlock:^(NSRelationshipDescription *relationship, NSArray *remoteObjects) {

        NSMutableArray *remoteIDs = [[NSMutableArray alloc] init];
        for (TBRemoteObject *remoteObject in remoteObjects) {

            id remoteID = [remoteObject jsonValueForUniqueIdentifier];

            if (remoteID) {
                [remoteIDs addObject:remoteID];

                [self gatherAllUniqueIdentifiersFromRemoteObject:remoteObject appendingToDictionary:remoteIdentifierMap];
            }
        }

        if (remoteIDs.count > 0) {
            TBAppendRemoteObjectIdentifiersOfClassToRemoteIdentifierMap(remoteIDs, relationship.destinationEntity.name, remoteIdentifierMap);
        }
    }];
}

- (void)updateManagedObjectToRemoteIDCacheForClass:(Class<TBUniquelySerializable>)class withRemoteIdentifiers:(NSSet *)remoteIdentifiers
{
    NSMutableSet *remoteIDs = [NSMutableSet setWithSet:remoteIdentifiers];
    [remoteIDs removeObject:[NSNull null]];
    if (!remoteIDs || remoteIDs.count == 0) {
        return;
    }

    NSArray *sortedRemoteIDs = [remoteIDs.allObjects sortedArrayUsingSelector:@selector(compare:)];
    if (!sortedRemoteIDs || sortedRemoteIDs.count == 0) {
        return;
    }

    NSString *remoteIDKeyPath = [class uniqueIdentifierLocalKey];

    NSExpressionDescription *objID = [[NSExpressionDescription alloc] init];
    objID.name = @"objectID";
    objID.expression = [NSExpression expressionForEvaluatedObject];
    objID.expressionResultType = NSObjectIDAttributeType;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass(class)];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(%K IN %@)", remoteIDKeyPath, sortedRemoteIDs]];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:@[remoteIDKeyPath, objID]];

    [self.context lock];
    [self.context performBlockAndWait:^{
        NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:nil];

        for (NSDictionary *dictionary in fetchedObjects) {
            NSString *key = TBCacheKeyForRemoteIdentifierOfClass(dictionary[remoteIDKeyPath], NSStringFromClass(class));
            self.remoteIDToManagedObjectCache[key] = dictionary[@"objectID"];
        }
    }];
    [self.context unlock];
}

- (void)addManagedObject:(NSManagedObject *)managedObject withRemoteObject:(TBRemoteObject *)remoteObject
{
    NSString *key = TBCacheKeyForRemoteIdentifierOfClass([remoteObject jsonValueForUniqueIdentifier], managedObject.entity.name);

    self.remoteIDToManagedObjectCache[key] = managedObject.objectID;
}

@end
