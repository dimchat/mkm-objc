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

+ (nullable NSString *)getString:(nullable id)value or:(nullable NSString *)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getString:value or:defaultValue];
}

+ (nullable NSNumber *)getNumber:(nullable id)value or:(nullable NSNumber *)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getNumber:value or:defaultValue];
}

+ (BOOL)getBool:(nullable id)value or:(BOOL)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getBool:value or:defaultValue];
}

+ (int)getInt:(nullable id)value or:(int)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getInt:value or:defaultValue];
}

+ (long)getLong:(nullable id)value or:(long)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getLong:value or:defaultValue];
}

+ (short)getShort:(nullable id)value or:(short)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getShort:value or:defaultValue];
}

+ (char)getChar:(nullable id)value or:(char)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getChar:value or:defaultValue];
}

+ (float)getFloat:(nullable id)value or:(float)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getFloat:value or:defaultValue];
}

+ (double)getDouble:(nullable id)value or:(double)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getDouble:value or:defaultValue];
}

+ (unsigned int)getUnsignedInt:(nullable id)value or:(unsigned int)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getUnsignedInt:value or:defaultValue];
}

+ (unsigned long)getUnsignedLong:(nullable id)value or:(unsigned long)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getUnsignedLong:value or:defaultValue];
}

+ (unsigned short)getUnsignedShort:(nullable id)value or:(unsigned short)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getUnsignedShort:value or:defaultValue];
}

+ (unsigned char)getUnsignedChar:(nullable id)value or:(unsigned char)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getUnsignedChar:value or:defaultValue];
}

+ (SInt8)getInt8:(nullable id)value or:(SInt8)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getInt8:value or:defaultValue];
}

+ (UInt8)getUInt8:(nullable id)value or:(UInt8)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getUInt8:value or:defaultValue];
}

+ (SInt16)getInt16:(nullable id)value or:(SInt16)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getInt16:value or:defaultValue];
}

+ (UInt16)getUInt16:(nullable id)value or:(UInt16)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getUInt16:value or:defaultValue];
}

+ (SInt32)getInt32:(nullable id)value or:(SInt32)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getInt32:value or:defaultValue];
}

+ (UInt32)getUInt32:(nullable id)value or:(UInt32)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getUInt32:value or:defaultValue];
}

+ (SInt64)getInt64:(nullable id)value or:(SInt64)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getInt64:value or:defaultValue];
}

+ (UInt64)getUInt64:(nullable id)value or:(UInt64)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getUInt64:value or:defaultValue];
}

+ (NSInteger)getInteger:(nullable id)value or:(NSInteger)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getInteger:value or:defaultValue];
}

+ (NSUInteger)getUnsignedInteger:(nullable id)value or:(NSUInteger)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getUnsignedInteger:value or:defaultValue];
}

+ (nullable NSDate *)getDate:(nullable id)value or:(nullable NSDate *)defaultValue {
    id<MKConverter> converter = [self getConverter];
    return [converter getDate:value or:defaultValue];
}

@end

#pragma mark - Data Converter

static inline NSNumber *str_to_num(NSString *text) {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [formatter numberFromString:text];
}

static inline NSString *trim(NSString *text) {
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [text stringByTrimmingCharactersInSet:whitespace];
}

static inline NSString *get_str(id value) {
    if ([value isKindOfClass:[NSString class]]) {
        // exactly
        return value;
    }
    // convert to NSString
    return [NSString stringWithFormat:@"%@", value];
}

static inline NSNumber *get_num(id value) {
    if ([value isKindOfClass:[NSNumber class]]) {
        // exactly
        return value;
    }
    // convert to NSNumber
    NSString *text = get_str(value);
    return str_to_num(text);
}

@implementation MKDataConverter

- (nullable NSString *)getString:(nullable id)value or:(nullable NSString *)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else {
        return get_str(value);
    }
}

- (nullable NSNumber *)getNumber:(nullable id)value or:(nullable NSNumber *)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else {
        return get_num(value);
    }
}

- (BOOL)getBool:(nullable id)value or:(BOOL)defaultValue {
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
        NSAssert(false, @"bool value error: '%@'", value);
        return NO;
    } else {
        text = [text lowercaseString];
    }
    NSDictionary *booleanStates = [MKConverter getBooleanStates];
    NSNumber *state = [booleanStates objectForKey:text];
    NSAssert(state != nil, @"bool value error: '%@'", value);
    return [state boolValue];
}

- (int)getInt:(nullable id)value or:(int)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num intValue];
}

- (long)getLong:(nullable id)value or:(long)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num longValue];
}

- (short)getShort:(nullable id)value or:(short)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num shortValue];
}

- (char)getChar:(nullable id)value or:(char)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num charValue];
}

- (float)getFloat:(nullable id)value or:(float)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num floatValue];
}

- (double)getDouble:(nullable id)value or:(double)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num doubleValue];
}

- (unsigned int)getUnsignedInt:(nullable id)value or:(unsigned int)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num unsignedIntValue];
}

- (unsigned long)getUnsignedLong:(nullable id)value or:(unsigned long)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num unsignedLongValue];
}

- (unsigned short)getUnsignedShort:(nullable id)value or:(unsigned short)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num unsignedShortValue];
}

- (unsigned char)getUnsignedChar:(nullable id)value or:(unsigned char)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num unsignedCharValue];
}

- (SInt8)getInt8:(nullable id)value or:(SInt8)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num charValue];
}

- (UInt8)getUInt8:(nullable id)value or:(UInt8)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num unsignedCharValue];
}

- (SInt16)getInt16:(nullable id)value or:(SInt16)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num shortValue];
}

- (UInt16)getUInt16:(nullable id)value or:(UInt16)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num unsignedShortValue];
}

- (SInt32)getInt32:(nullable id)value or:(SInt32)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
#if __LP64__
    return [num intValue];
#else
    return [num longValue];
#endif
}

- (UInt32)getUInt32:(nullable id)value or:(UInt32)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
#if __LP64__
    return [num unsignedIntValue];
#else
    return [num unsignedLongValue];
#endif
}

- (SInt64)getInt64:(nullable id)value or:(SInt64)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num longLongValue];
}

- (UInt64)getUInt64:(nullable id)value or:(UInt64)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num unsignedLongLongValue];
}

- (NSInteger)getInteger:(nullable id)value or:(NSInteger)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num integerValue];
}

- (NSUInteger)getUnsignedInteger:(nullable id)value or:(NSUInteger)defaultValue {
    if (value == nil) {
        return defaultValue;
    }
    NSNumber *num = get_num(value);
    return [num unsignedIntegerValue];
}

- (nullable NSDate *)getDate:(nullable id)value or:(nullable NSDate *)defaultValue {
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSDate class]]) {
        // exactly
        return value;
    }
    NSNumber *num = get_num(value);
    double seconds = [num doubleValue];
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

@end
