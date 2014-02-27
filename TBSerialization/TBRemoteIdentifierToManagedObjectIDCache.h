//
//  TBRemoteIdentifierToManagedObjectIDCache.h
//  TBPersistence
//
//  Created by Theodore Calmes on 11/13/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TBRemoteObject;

/** The `TBRemoteIdentifierToManagedObjectIDCache` provides a very quick solution to existance checking. Given an array of `TBRemoteObject` instances it will parse out every class' remote identifiers and perform batch `NSManagedObjectID` fetches on these and cache the result for quick access by `TBManagedObjectTransformer`.
 */

@interface TBRemoteIdentifierToManagedObjectIDCache : NSObject

/** The context property is the managed object context where all operations happen for both the managed object transformer and the cache. It is recommended to use an `NSPrivateQueueContext` type of `NSManagedObjectContext`.
 */
@property (strong, nonatomic, readonly) NSManagedObjectContext *context;

/** This is the init method you should be using. This object will not work via the traditional init method.
 @param context the context which will perform all the fetches.
 @return an instance of `TBRemoteIdentifierToManagedObjectIDCache` to be used alongside `TBManagedObjectTransformer`.
 */
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context;

/** This method uses the cache to retrieve an existing `NSManagedObject` corresponding to the passed in `TBRemoteObject` instance. If no object is found the method will return nil.
 @param remoteObject, a remote object instance which has a unique identifier.
 @return an existing `NSManagedObject` instance from the cache.
 */
- (NSManagedObject *)managedObjectForRemoteObject:(TBRemoteObject *)remoteObject;

/** Use this method to add remote objects which unique identifiers to the cache. This method will execute a potentially long fetch request so make sure it happens on a background thread.
 @param an array of remote objects with unique identifiers.
 */
- (void)updateCacheWithRemoteObjects:(NSArray *)remoteObjects;

/** Removes all objects from the cache. */
- (void)clearCache;

/** Add a specific managed object and remote object pair to the cache.
 @param managedObject the managed object instance you would like to add to the cache.
 @param remoteObject the remote object to pair with the managed object.
 */
- (void)addManagedObject:(NSManagedObject *)managedObject withRemoteObject:(TBRemoteObject *)remoteObject;

@end
