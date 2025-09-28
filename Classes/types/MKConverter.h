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
//  MKConverter.h
//  MingKeMing
//
//  Created by Albert Moky on 2025/9/28.
//  Copyright © 2025 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Data Converter
 */
@protocol MKConverter <NSObject>

- (nullable NSString *)getString:(id)value or:(nullable NSString *)defaultValue;

- (nullable NSNumber *)getNumber:(id)value or:(nullable NSNumber *)defaultValue;

/**
 *  assume value can be a config string:
 *      'true', 'false', 'yes', 'no', 'on', 'off', '1', '0', ...
 */
- (BOOL)                   getBool:(id)value or:(BOOL)defaultValue;

- (int)                     getInt:(id)value or:(int)defaultValue;
- (long)                   getLong:(id)value or:(long)defaultValue;
- (short)                 getShort:(id)value or:(short)defaultValue;
- (char)                   getChar:(id)value or:(char)defaultValue;

- (float)                 getFloat:(id)value or:(float)defaultValue;
- (double)               getDouble:(id)value or:(double)defaultValue;

- (unsigned int)    getUnsignedInt:(id)value or:(unsigned int)defaultValue;
- (unsigned long)  getUnsignedLong:(id)value or:(unsigned long)defaultValue;
- (unsigned short)getUnsignedShort:(id)value or:(unsigned short)defaultValue;
- (unsigned char)  getUnsignedChar:(id)value or:(unsigned char)defaultValue;

- (NSInteger)           getInteger:(id)value or:(NSInteger)defaultValue;
- (NSUInteger)  getUnsignedInteger:(id)value or:(NSUInteger)defaultValue;

/**
 *  assume value can be a timestamp (seconds from 1970-01-01 00:00:00)
 */
- (nullable NSDate *)getDate:(id)value or:(nullable NSDate *)defaultValue;

@end

#pragma mark - Interface

@interface MKConverter : NSObject

+ (NSMutableDictionary<NSString *, NSNumber *> *)getBooleanStates;

+ (NSUInteger)getMaxBooleanLength;
+ (void)setMaxBooleanLength:(NSUInteger)maxLength;

+ (id<MKConverter>)getConverter;
+ (void)setConverter:(id<MKConverter>)converter;

//
//  Data Convert Interface
//

+ (nullable NSString *)getString:(id)value or:(nullable NSString *)defaultValue;

+ (nullable NSNumber *)getNumber:(id)value or:(nullable NSNumber *)defaultValue;

+ (BOOL)                   getBool:(id)value or:(BOOL)defaultValue;

+ (int)                     getInt:(id)value or:(int)defaultValue;
+ (long)                   getLong:(id)value or:(long)defaultValue;
+ (short)                 getShort:(id)value or:(short)defaultValue;
+ (char)                   getChar:(id)value or:(char)defaultValue;

+ (float)                 getFloat:(id)value or:(float)defaultValue;
+ (double)               getDouble:(id)value or:(double)defaultValue;

+ (unsigned int)    getUnsignedInt:(id)value or:(unsigned int)defaultValue;
+ (unsigned long)  getUnsignedLong:(id)value or:(unsigned long)defaultValue;
+ (unsigned short)getUnsignedShort:(id)value or:(unsigned short)defaultValue;
+ (unsigned char)  getUnsignedChar:(id)value or:(unsigned char)defaultValue;

+ (NSInteger)           getInteger:(id)value or:(NSInteger)defaultValue;
+ (NSUInteger)  getUnsignedInteger:(id)value or:(NSUInteger)defaultValue;

+ (nullable NSDate *)getDate:(id)value or:(nullable NSDate *)defaultValue;

@end

#pragma mark - Data Converter

/**
 *  Base Converter
 */
@interface MKDataConverter : NSObject<MKConverter>

@end

#pragma mark - Convert data with default value

#define MKConvertString(V, D)        [MKConverter getString:(V) or:(D)]
#define MKConvertNumber(V, D)        [MKConverter getNumber:(V) or:(D)]

#define MKConvertBool(V, D)          [MKConverter          getBool:(V) or:(D)]

#define MKConvertInt(V, D)           [MKConverter           getInt:(V) or:(D)]
#define MKConvertLong(V, D)          [MKConverter          getLong:(V) or:(D)]
#define MKConvertShort(V, D)         [MKConverter         getShort:(V) or:(D)]
#define MKConvertChar(V, D)          [MKConverter          getChar:(V) or:(D)]

#define MKConvertFloat(V, D)         [MKConverter         getFloat:(V) or:(D)]
#define MKConvertDouble(V, D)        [MKConverter        getDouble:(V) or:(D)]

#define MKConvertUnsignedInt(V, D)   [MKConverter   getUnsignedInt:(V) or:(D)]
#define MKConvertUnsignedLong(V, D)  [MKConverter  getUnsignedLong:(V) or:(D)]
#define MKConvertUnsignedShort(V, D) [MKConverter getUnsignedShort:(V) or:(D)]
#define MKConvertUnsignedChar(V, D)  [MKConverter  getUnsignedChar:(V) or:(D)]

#define MKConvertInteger(V, D)         [MKConverter         getInteger:(V) or:(D)]
#define MKConvertUnsignedInteger(V, D) [MKConverter getUnsignedInteger:(V) or:(D)]

#define MKConvertDate(V, D)          [MKConverter getDate:(V) or:(D)]

NS_ASSUME_NONNULL_END
