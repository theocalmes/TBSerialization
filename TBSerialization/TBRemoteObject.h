//
//  TBJSONObject.h
//  TBPersistence
//
//  Created by Theodore Calmes on 11/6/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol TBSerializable;

/** `TBRemoteObject` is a bridge between JSON and an `NSManagedObject` subclass's property key paths. This class allows you to access a JSON dictionary as if you were accessing methods on an `NSManagedObject` instance.
 */

@interface TBRemoteObject : NSObject

/** @name Properties */

/** The localObjectClass should at the very least conform to `TBSerializable` and be an `NSManagedObject` subclass. */
@property (assign, nonatomic, readonly) Class<TBSerializable> localObjectClass;

/** The remoteObjectDictionary is the JSON dictionary which represents the object you would like to parse. */
@property (strong, nonatomic, readonly) NSDictionary *remoteObjectDictionary;

/** @name Initalizer */

/** You MUST use this init method instead of the standard init method.
 @param localObjectClass an `NSManagedObject` subclass conforming to either `TBSerializable` or `TBUniquelySerializable`.
 @param remoteObjectDictionary JSON dictionary which represents the object you would like to parse.
 @return a `TBRemoteObject` instance.
 @see remoteObjectDictionary
 @see localObjectClass
 */
- (id)initWithClass:(Class<TBSerializable>)localObjectClass dictionary:(NSDictionary *)remoteObjectDictionary;

/** @name Accessing values and keypaths */

/** Uses the toObjectMap from the localObjectClass's `TBPropertyMap` and the given localKey to get to the JSON keyPath corresponding to this local key. 
 EX:
    Given a toObjectMap = {localKey : JSONKey}, and you pass in "localKey" this method will return "JSONKey". If localKey is not found, it will return "localKey" (this allows you to not explicitly define the keys which match on both the JSON end and the managed object end).
 @param localKey a keypath to the NSManagedObject property.
 @return the keypath to the corresponding JSON value.
 @see jsonValueForLocalKey:
 @see jsonKeyPathForProperty:
 @see jsonValueForProperty:
 */
- (NSString *)jsonKeyPathForLocalKey:(NSString *)localKey;

/** This method gets the keypath from passing localKey to `jsonKeyPathForLocalKey:` and calls `valueForKeyPath:` on remoteObjectDictionary.
 @param localKey a keypath to the NSManagedObject property.
 @return the corresponding value found in `remoteObjectDictionary`.
 @see jsonKeyPathForLocalKey:
 @see jsonKeyPathForProperty:
 @see jsonValueForProperty:
 */
- (id)jsonValueForLocalKey:(NSString *)localKey;

/** This method is the same as `jsonKeyPathForLocalKey:` but instead takes in an `NSPropertyDescription`.
 @param property the property for which you would like to have the keypath for.
 @return the keypath to the corresponding JSON value.
 @see jsonKeyPathForLocalKey:
 @see jsonValueForLocalKey:
 @see jsonValueForProperty:
 */
- (NSString *)jsonKeyPathForProperty:(NSPropertyDescription *)property;

/** This method is the same as `jsonValueForLocalKey:` but instead takes in an `NSPropertyDescription`.
 @param property the property for which you would like to have the JSON value for.
 @return the corresponding value found in `remoteObjectDictionary`.
 @see jsonKeyPathForLocalKey:
 @see jsonValueForLocalKey:
 @see jsonKeyPathForProperty:
 */
- (id)jsonValueForProperty:(NSPropertyDescription *)property;

- (BOOL)shouldConvertValueForLocalKeyToJSON:(NSString *)localKey;
- (BOOL)shouldConvertValueForPropertyToJSON:(NSPropertyDescription *)property;

/** @name Uniquing */

/** @return whether the localObjectClass has a unique identifier */
- (BOOL)hasUniqueIdentifier;

/** @return the keyPath to the unique identifier residing in the JSON dictionary. */
- (NSString *)localKeyPathForUniqueIdentifier;

/** @return the value to the unique identifier residing in the JSON dictionary. */
- (NSNumber *)jsonValueForUniqueIdentifier;

@end
