//
//  TBManagedObjectTransformer.h
//  TBPersistence
//
//  Created by Theodore Calmes on 11/8/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "TBSerialization.h"

@class TBRemoteIdentifierToManagedObjectIDCache;

/**
 *  The `TBManagedObjectTransformer`'s job is to create or update `NSManagedObject` instances with JSON data stored in a `TBRemoteObject`. The transformer takes in a `TBRemoteIdentifierToManagedObjectIDCache` instance which it will use to perform existance checking on the current core data DB. You MUST provide it with a cache object for existance checking to happen.
 */

@interface TBManagedObjectTransformer : NSObject

/**
 *  The initializer, you must use this one and not `-init`.
 *
 *  @param cache TBRemoteIdentifierToManagedObjectIDCache` instance filled with remote objects which will speed up existance checking.
 *
 *  @return an insatnce of `TBManagedObjectTransformer` to use for creating managed objects.
 */
- (id)initWithRemoteIDCache:(TBRemoteIdentifierToManagedObjectIDCache *)cache;

/**
 *  Given a `TBRemoteObject` instance generate an `NSManagedObject` instance out of it. If the `NSManagedObject` subclass conforms to `TBUniquelySerializable` then the cache will be consulted to find an existing object, if not found a new one will be created.
 *
 *  @param object the remote object built using JSON from the server.
 *
 *  @return an instance of your `NSManagedObject` subclass.
 */
- (NSManagedObject *)managedObjectForRemoteObject:(TBRemoteObject *)object;

/**
 *  Update an existing `NSManagedObject` instance using a `TBRemoteObject` instance.
 *
 *  @param managedObject this is the managed object to which is to be updated.
 *  @param remoteObject  the remote object containing the JSON data to update your managed object with.
 */
- (void)updateManagedObject:(NSManagedObject *)managedObject withRemoteObject:(TBRemoteObject *)remoteObject;

+ (NSDictionary *)JSONDictionaryForManagedObject:(NSManagedObject<TBSerializable> *)managedObject;

@end
