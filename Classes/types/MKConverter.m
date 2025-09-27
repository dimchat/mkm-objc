// license: https://mit-license.org
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2025 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  MKConverter.m
//  MingKeMing
//
//  Created by Albert Moky on 2025/9/28.
//  Copyright © 2025 DIM Group. All rights reserved.
//

#import "MKConverter.h"

@implementation MKConverter

static NSMutableDictionary<NSString *, NSNumber *> *s_boolean_states = nil;
static NSUInteger s_max_boolean_length = 9; // [@"undefined" length];

static id<MKConverter> s_converter;

+ (NSMutableDictionary<NSString *, NSNumber *> *)getBooleanStates {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_boolean_states = [NSMutableDictionary dictionaryWithDictionary:@{
            @"1": @(YES), @"yes": @(YES), @"true": @(YES), @"on": @(YES),
            
            @"0": @(NO), @"no": @(NO), @"false": @(NO), @"off": @(NO),
            //@"+0": @(NO), @"-0": @(NO), @"0.0": @(NO), @"+0.0": @(NO), @"-0.0": @(NO),
            @"null": @(NO), @"none": @(NO), @"undefined": @(NO),
        }];
    });
    return s_boolean_states;
}

+ (NSUInteger)getMaxBooleanLength {
    return s_max_boolean_length;
}

+ (void)setMaxBooleanLength:(NSUInteger)maxLength {
    s_max_boolean_length = maxLength;
}

+ (id<MKConverter>)getConverter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!s_converter) {
            s_converter = [[MKDataConverter alloc] init];
        }
    });
    return s_converter;
}

+ (void)setConverter:(id<MKConverter>)converter {
    s_converter = converter;
}

//
//  Data Convert Interface
//

+ (nullable NSString *)getString:(id)value defaultValue:(nullable NSString *)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getString:value defaultValue:defaultValue];
}

+ (nullable NSNumber *)getNumber:(id)value defaultValue:(nullable NSNumber *)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getNumber:value defaultValue:defaultValue];
}

+ (BOOL)getBool:(id)value defaultValue:(BOOL)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getBool:value defaultValue:defaultValue];
}

+ (int)getInt:(id)value defaultValue:(int)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getInt:value defaultValue:defaultValue];
}

+ (long)getLong:(id)value defaultValue:(long)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getLong:value defaultValue:defaultValue];
}

+ (short)getShort:(id)value defaultValue:(short)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getShort:value defaultValue:defaultValue];
}

+ (char)getChar:(id)value defaultValue:(char)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getChar:value defaultValue:defaultValue];
}

+ (float)getFloat:(id)value defaultValue:(float)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getFloat:value defaultValue:defaultValue];
}

+ (double)getDouble:(id)value defaultValue:(double)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getDouble:value defaultValue:defaultValue];
}

+ (unsigned int)getUnsignedInt:(id)value defaultValue:(unsigned int)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getUnsignedInt:value defaultValue:defaultValue];
}

+ (unsigned long)getUnsignedLong:(id)value defaultValue:(unsigned long)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getUnsignedLong:value defaultValue:defaultValue];
}

+ (unsigned short)getUnsignedShort:(id)value defaultValue:(unsigned short)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getUnsignedShort:value defaultValue:defaultValue];
}

+ (unsigned char)getUnsignedChar:(id)value defaultValue:(unsigned char)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getUnsignedChar:value defaultValue:defaultValue];
}

+ (NSInteger)getInteger:(id)value defaultValue:(NSInteger)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getInteger:value defaultValue:defaultValue];
}

+ (NSUInteger)getUnsignedInteger:(id)value defaultValue:(NSUInteger)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getUnsignedInteger:value defaultValue:defaultValue];
}

+ (nullable NSDate *)getDate:(id)value defaultValue:(nullable NSDate *)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getDate:value defaultValue:defaultValue];
}

@end

#pragma mark - Data Converter

static inline NSString *get_str(id value) {
    if ([value isKindOfClass:[NSString class]]) {
        // exactly
        return value;
    }
    // convert to NSString
    return [NSString stringWithFormat:@"%@", value];
}

static inline NSNumber *str_to_num(NSString *text) {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [formatter numberFromString:text];
}

static inline NSString *trim(NSString *text) {
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [text stringByTrimmingCharactersInSet:whitespace];
}

@implementation MKDataConverter

- (nullable NSString *)getString:(id)value defaultValue:(nullable NSString *)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSString class]]) {
        // exactly
        return value;
    } else {
        NSAssert(NO, @"not a string value: '%@'", value);
        return [NSString stringWithFormat:@"%@", value];
    }
}

- (nullable NSNumber *)getNumber:(id)value defaultValue:(nullable NSNumber *)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        // exactly
        return value;
    }
    NSString *text = get_str(value);
    return str_to_num(text);
}

- (BOOL)getBool:(id)value defaultValue:(BOOL)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        // exactly
        return [value boolValue];
    }
    NSString *text = get_str(value);
    text = trim(text);
    NSUInteger size = [text length];
    if (size == 0) {
        return NO;
    } else if (size > [MKConverter getMaxBooleanLength]) {
        NSAssert(NO, @"bool value error: '%@'", value);
        return NO;
    } else {
        text = [text lowercaseString];
    }
    id booleanStates = [MKConverter getBooleanStates];
    NSNumber *state = [booleanStates objectForKey:text];
    NSAssert(state != nil, @"bool value error: '%@'", value);
    return state != 0;
}

- (int)getInt:(id)value defaultValue:(int)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        // exactly
    } else {
        NSString *text = get_str(value);
        value = str_to_num(text);
    }
    return [value intValue];
}

- (long)getLong:(id)value defaultValue:(long)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        // exactly
    } else {
        NSString *text = get_str(value);
        value = str_to_num(text);
    }
    return [value longValue];
}

- (short)getShort:(id)value defaultValue:(short)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        // exactly
    } else {
        NSString *text = get_str(value);
        value = str_to_num(text);
    }
    return [value shortValue];
}

- (char)getChar:(id)value defaultValue:(char)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        // exactly
    } else {
        NSString *text = get_str(value);
        value = str_to_num(text);
    }
    return [value charValue];
}

- (float)getFloat:(id)value defaultValue:(float)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        // exactly
    } else {
        NSString *text = get_str(value);
        value = str_to_num(text);
    }
    return [value floatValue];
}

- (double)getDouble:(id)value defaultValue:(double)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        // exactly
    } else {
        NSString *text = get_str(value);
        value = str_to_num(text);
    }
    return [value doubleValue];
}

- (unsigned int)getUnsignedInt:(id)value defaultValue:(unsigned int)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        // exactly
    } else {
        NSString *text = get_str(value);
        value = str_to_num(text);
    }
    return [value unsignedIntValue];
}

- (unsigned long)getUnsignedLong:(id)value defaultValue:(unsigned long)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        // exactly
    } else {
        NSString *text = get_str(value);
        value = str_to_num(text);
    }
    return [value unsignedLongValue];
}

- (unsigned short)getUnsignedShort:(id)value defaultValue:(unsigned short)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        // exactly
    } else {
        NSString *text = get_str(value);
        value = str_to_num(text);
    }
    return [value unsignedShortValue];
}

- (unsigned char)getUnsignedChar:(id)value defaultValue:(unsigned char)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        // exactly
    } else {
        NSString *text = get_str(value);
        value = str_to_num(text);
    }
    return [value unsignedCharValue];
}

- (NSInteger)getInteger:(id)value defaultValue:(NSInteger)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        // exactly
    } else {
        NSString *text = get_str(value);
        value = str_to_num(text);
    }
    return [value integerValue];
}

- (NSUInteger)getUnsignedInteger:(id)value defaultValue:(NSUInteger)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        // exactly
    } else {
        NSString *text = get_str(value);
        value = str_to_num(text);
    }
    return [value unsignedIntegerValue];
}

- (nullable NSDate *)getDate:(id)value defaultValue:(nullable NSDate *)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSDate class]]) {
        // exactly
        return value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        // convert to Date
    } else {
        NSString *text = get_str(value);
        value = str_to_num(text);
    }
    double seconds = [value doubleValue];
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

@end
