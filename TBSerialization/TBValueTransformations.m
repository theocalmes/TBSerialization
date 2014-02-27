//
//  TBValueTransformations.m
//  TBPersistence
//
//  Created by Theodore Calmes on 11/8/13.
//  Copyright (c) 2013 thoughtbot. All rights reserved.
//

#import "TBValueTransformations.h"

@implementation TBValueTransformations

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    });

    return formatter;
}

+ (NSDateFormatter *)fallbackDateFormatter
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'+00:00'";
        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    });

    return formatter;
}

+ (NSDate *)dateFromString:(NSString *)string
{
    NSParameterAssert(string);

    NSDate *date = [[self dateFormatter] dateFromString:string];

    if (!date) {
        date = [[self fallbackDateFormatter] dateFromString:string];
    }

    return date;
}

+ (NSString *)stringFromDate:(NSDate *)date
{
    NSParameterAssert(date);

    NSString *dateString = nil;

    dateString = [[self dateFormatter] stringFromDate:date];

    if (!dateString) {
        NSLog(@"Failed to transform date: %@", date);
    }

    return dateString;
}

+ (id)transformJSONValue:(id)jsonValue toAttributeType:(NSAttributeType)type
{
    id transformedValue = nil;

    switch (type) {
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
            if ([jsonValue isKindOfClass:[NSNumber class]]) {
                transformedValue = @([jsonValue longLongValue]);
            } else if ([jsonValue isKindOfClass:[NSString class]]) {
                transformedValue = @([jsonValue doubleValue]);
            }

            break;

        case NSDecimalAttributeType:
            if ([jsonValue respondsToSelector:@selector(decimalValue)]) {
                transformedValue = [[NSDecimalNumber alloc] initWithDecimal:[jsonValue decimalValue]];
            }

            break;

        case NSDoubleAttributeType:
            if ([jsonValue respondsToSelector:@selector(doubleValue)]) {
                transformedValue = @([jsonValue doubleValue]);
            }

            break;

        case NSFloatAttributeType:
            if ([jsonValue respondsToSelector:@selector(floatValue)]) {
                transformedValue = @([jsonValue floatValue]);
            }

            break;

        case NSStringAttributeType:
            if ([jsonValue isKindOfClass:[NSString class]]) {
                transformedValue = [jsonValue copy];
            } else if ([jsonValue respondsToSelector:@selector(stringValue)]) {
                transformedValue = [[jsonValue stringValue] copy];
            }

            break;

        case NSBooleanAttributeType:
            if ([jsonValue respondsToSelector:@selector(boolValue)]) {
                transformedValue = @([jsonValue boolValue]);
            }

            break;

        case NSDateAttributeType:
            if ([jsonValue isKindOfClass:[NSNumber class]]) {
                transformedValue = [NSDate dateWithTimeIntervalSince1970:[jsonValue doubleValue]];
            } else if ([jsonValue isKindOfClass:[NSString class]]) {
                transformedValue = [self dateFromString:jsonValue];
            }

            break;

        case NSUndefinedAttributeType:
        case NSBinaryDataAttributeType:
        case NSTransformableAttributeType:
        case NSObjectIDAttributeType:
        default:
            break;
    }
    
    if (!transformedValue) {
        return nil;
    }
    
    return transformedValue;
}

@end
