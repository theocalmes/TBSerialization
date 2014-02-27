//
//  TBValueTransformations.h
//  TBPersistence
//
//  Created by Theodore Calmes on 11/8/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 *  TBValueTransformations transforms JSON values to values more friendly for core data to handle. You can use this class out of the box, or subclass it to handle specific situations. The date methods have been exposed for your convenience as it is most likely the one that will need changing.
 */

@interface TBValueTransformations : NSObject

/**
 *  transforms JSON values to values more friendly for core data to handle.
 *
 *  @param jsonValue value coming from a JSON dictionary.
 *  @param attribute the attribute type to use for transforming the jsonValue.
 *
 *  @return the transformed value.
 */
+ (id)transformJSONValue:(id)jsonValue toAttributeType:(NSAttributeType)attribute;

/** @name Subclass */

/**
 *  Convert a string to a NSDate instance.
 *
 *  @param string the date as a string.
 *
 *  @return an NSDate instance.
 */
+ (NSDate *)dateFromString:(NSString *)string;

/**
 *  Converts an NSDate instance to a string.
 *
 *  @param date the date.
 *
 *  @return the string format for the date.
 */
+ (NSString *)stringFromDate:(NSDate *)date;

@end
