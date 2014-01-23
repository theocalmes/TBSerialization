//
//  TBAttributeMap.h
//  TBPersistence
//
//  Created by Theodore Calmes on 11/6/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import <Foundation/Foundation.h>

/** The `TBPropertyMap` allows you to define the mapping between core data and JSON. The dictionary keys will represent the keypaths to the core data properties and the dictionary values will represent the keys in the JSON dictionaries.
 */

@interface TBPropertyMap : NSObject

/** This property lets you define how your core data object will be populated from the JSON. Key values are keypaths to the core data properties and the values are the keys to the JSON dictionary.
 */
@property (strong, nonatomic) NSDictionary *toObjectMap;

/** NOT IMPLEMENTED YET */
@property (strong, nonatomic) NSSet *excludedSerializationKeys;

@end
