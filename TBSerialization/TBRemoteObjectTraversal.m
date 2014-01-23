//
//  TBRemoteObjectTraversal.m
//  TBPersistence
//
//  Created by Theodore Calmes on 11/7/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "TBRemoteObjectTraversal.h"
#import "TBSerializable.h"
#import "TBRemoteObject.h"

@implementation TBRemoteObjectTraversal

+ (void)traverseRelationshipsForEntity:(NSEntityDescription *)entity withDictionary:(NSDictionary *)dictionary traversalBlock:(TBEntityRelationshipTraversalBlock)block
{
    NSDictionary *relationships = entity.relationshipsByName;

    if (!relationships.count) {
        return;
    }

    Class <TBSerializable> entityClass = NSClassFromString(entity.name);
    TBRemoteObject *remoteObject = [[TBRemoteObject alloc] initWithClass:entityClass dictionary:dictionary];

    for (NSRelationshipDescription *relationship in relationships.allValues) {

        id jsonValue = [remoteObject jsonValueForProperty:relationship];

        if (!jsonValue) {
            continue;
        }

        NSMutableArray *jsonValues = [[NSMutableArray alloc] init];

        if ([jsonValue classForCoder] == [NSArray class]) {
            [jsonValues addObjectsFromArray:jsonValue];
        } else {
            [jsonValues addObject:jsonValue];
        }

        NSMutableArray *remoteObjects = [[NSMutableArray alloc] init];

        for (id json in jsonValues) {
            if ([json isKindOfClass:[NSDictionary class]]) {
                TBRemoteObject *relationshipRemoteObject = [[TBRemoteObject alloc] initWithClass:NSClassFromString(relationship.destinationEntity.name) dictionary:json];
                [remoteObjects addObject:relationshipRemoteObject];
            }
        }

        block(relationship, remoteObjects);
    }
}

@end
