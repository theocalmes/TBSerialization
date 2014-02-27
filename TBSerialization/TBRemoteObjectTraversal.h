//
//  TBRemoteObjectTraversal.h
//  TBPersistence
//
//  Created by Theodore Calmes on 11/7/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import <CoreData/CoreData.h>

@class TBRemoteObjectTraversal;
@protocol TBSerializable;

/**
 *  The TBEntityRelationshipTraversalBlock is called whenever the relationship traverser hit a relationship.
 *
 *  @param relationship  the current relationship corresponding to with the remoteObjects.
 *  @param remoteObjects the values of the current relationship.
 *
 *  @return void
 */
typedef void(^TBEntityRelationshipTraversalBlock)(NSRelationshipDescription *relationship, NSArray *remoteObjects);

/**
 *  The `TBRemoteObjectTraversal` loops through an entity's relationships and access the subdictionaries from the JSON and build up `TBRemoteObjects` from them. It will then fire a block with the relationship and its remote objects.
 */

@interface TBRemoteObjectTraversal : NSObject

/**
 *  This method loops through an entity's relationships.
 *
 *  @param entity     your NSManagedObject subclass entity description.
 *  @param dictionary a JSON dictionary representing the entity.
 *  @param block      a `TBEntityRelationshipTraversalBlock`.
 *  @see TBEntityRelationshipTraversalBlock
 */
+ (void)traverseRelationshipsForEntity:(NSEntityDescription *)entity withDictionary:(NSDictionary *)dictionary traversalBlock:(TBEntityRelationshipTraversalBlock)block;

@end
