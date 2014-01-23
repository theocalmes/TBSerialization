//
//  TBSerializable.h
//  TBPersistence
//
//  Created by Theodore Calmes on 11/6/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBPropertyMap, TBRemoteObject;

/** The `TBSerializable` protocol must be conformed to by managed objects for parsing to work.
 These protocols serve as the bridge connecting an `NSManagedObject` and a JSON dictionary.
 */

@protocol TBSerializable <NSObject>

@required
/** This class instance will return a `TBPropertyMap` which will serve as the bridge connecting your `NSManagedObject` subclass to a JSON dictionary.
 @return TBPropertyMap the map with local keys (representing core data properties) on the left and JSON dictionary keys on the right.
 */
+ (TBPropertyMap *)localToRemoteMap;

@optional
/** Implement this method is called after the properties and relationships of your `NSManagedObject` subclass have been updated.
 @param remoteObject a `TBRemoteObject` which contains the JSON as its `remoteObjectDictionary`.
 */
- (void)didUpdateWithRemoteObject:(TBRemoteObject *)remoteObject;

@end

/** The `TBUniquelySerializable` protocol extends `TBSerializable` by adding uniquing. If your object conforms to this protocol, we will attempt to fetch a managed object instance with a matching unique identifier. If found we will update the instance, if not found we will create a new one.
 */

@protocol TBUniquelySerializable <TBSerializable>

@required

/** Given a `TBRemoteObject` extract the unique id from it.
 @param remoteObject a `TBRemoteObject` which contains the JSON as its `remoteObjectDictionary`.
 @return a unique numerical value.
 */
+ (NSNumber *)uniqueIdentifierFromRemoteObject:(TBRemoteObject *)remoteObject;

/** This method should return the property key path for the unique id on your `NSManagedObject` subclass.
 @return the keypath to the unique id.
 */
+ (NSString *)uniqueIdentifierLocalKey;

@optional
/** Given a `TBRemoteObject` decide whether you want to serialize the object or not.
 @param remoteObject a `TBRemoteObject` which contains the JSON as its `remoteObjectDictionary`.
 @return YES if you want to serialize or NO if you don't.
 */
- (BOOL)shouldSerializeWithRemoteObject:(TBRemoteObject *)remoteObject;

@end
