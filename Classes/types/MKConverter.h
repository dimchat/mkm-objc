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

- (nullable NSString *)getString:(nullable id)value or:(nullable NSString *)defaultValue;
- (nullable NSNumber *)getNumber:(nullable id)value or:(nullable NSNumber *)defaultValue;

/**
 *  assume value can be a config string:
 *      'true', 'false', 'yes', 'no', 'on', 'off', '1', '0', ...
 */
- (BOOL)                   getBool:(nullable id)value or:(BOOL)defaultValue;

- (int)                     getInt:(nullable id)value or:(int)defaultValue;
- (long)                   getLong:(nullable id)value or:(long)defaultValue;
- (short)                 getShort:(nullable id)value or:(short)defaultValue;
- (char)                   getChar:(nullable id)value or:(char)defaultValue;

- (float)                 getFloat:(nullable id)value or:(float)defaultValue;
- (double)               getDouble:(nullable id)value or:(double)defaultValue;

- (unsigned int)    getUnsignedInt:(nullable id)value or:(unsigned int)defaultValue;
- (unsigned long)  getUnsignedLong:(nullable id)value or:(unsigned long)defaultValue;
- (unsigned short)getUnsignedShort:(nullable id)value or:(unsigned short)defaultValue;
- (unsigned char)  getUnsignedChar:(nullable id)value or:(unsigned char)defaultValue;

- (SInt8)                  getInt8:(nullable id)value or:(SInt8)defaultValue;
- (UInt8)                 getUInt8:(nullable id)value or:(UInt8)defaultValue;
- (SInt16)                getInt16:(nullable id)value or:(SInt16)defaultValue;
- (UInt16)               getUInt16:(nullable id)value or:(UInt16)defaultValue;
- (SInt32)                getInt32:(nullable id)value or:(SInt32)defaultValue;
- (UInt32)               getUInt32:(nullable id)value or:(UInt32)defaultValue;
- (SInt64)                getInt64:(nullable id)value or:(SInt64)defaultValue;
- (UInt64)               getUInt64:(nullable id)value or:(UInt64)defaultValue;

- (NSInteger)           getInteger:(nullable id)value or:(NSInteger)defaultValue;
- (NSUInteger)  getUnsignedInteger:(nullable id)value or:(NSUInteger)defaultValue;

/**
 *  assume value can be a timestamp (seconds from 1970-01-01 00:00:00)
 */
- (nullable NSDate *)getDate:(nullable id)value or:(nullable NSDate *)defaultValue;

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

+ (nullable NSString *)getString:(nullable id)value or:(nullable NSString *)defaultValue;
+ (nullable NSNumber *)getNumber:(nullable id)value or:(nullable NSNumber *)defaultValue;

+ (BOOL)                   getBool:(nullable id)value or:(BOOL)defaultValue;

+ (int)                     getInt:(nullable id)value or:(int)defaultValue;
+ (long)                   getLong:(nullable id)value or:(long)defaultValue;
+ (short)                 getShort:(nullable id)value or:(short)defaultValue;
+ (char)                   getChar:(nullable id)value or:(char)defaultValue;

+ (float)                 getFloat:(nullable id)value or:(float)defaultValue;
+ (double)               getDouble:(nullable id)value or:(double)defaultValue;

+ (unsigned int)    getUnsignedInt:(nullable id)value or:(unsigned int)defaultValue;
+ (unsigned long)  getUnsignedLong:(nullable id)value or:(unsigned long)defaultValue;
+ (unsigned short)getUnsignedShort:(nullable id)value or:(unsigned short)defaultValue;
+ (unsigned char)  getUnsignedChar:(nullable id)value or:(unsigned char)defaultValue;

+ (SInt8)                  getInt8:(nullable id)value or:(SInt8)defaultValue;
+ (UInt8)                 getUInt8:(nullable id)value or:(UInt8)defaultValue;
+ (SInt16)                getInt16:(nullable id)value or:(SInt16)defaultValue;
+ (UInt16)               getUInt16:(nullable id)value or:(UInt16)defaultValue;
+ (SInt32)                getInt32:(nullable id)value or:(SInt32)defaultValue;
+ (UInt32)               getUInt32:(nullable id)value or:(UInt32)defaultValue;
+ (SInt64)                getInt64:(nullable id)value or:(SInt64)defaultValue;
+ (UInt64)               getUInt64:(nullable id)value or:(UInt64)defaultValue;

+ (NSInteger)           getInteger:(nullable id)value or:(NSInteger)defaultValue;
+ (NSUInteger)  getUnsignedInteger:(nullable id)value or:(NSUInteger)defaultValue;

+ (nullable NSDate *)getDate:(nullable id)value or:(nullable NSDate *)defaultValue;

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

#define MKConvertInt8(V, D)          [MKConverter          getInt8:(V) or:(D)]
#define MKConvertUInt8(V, D)         [MKConverter         getUInt8:(V) or:(D)]
#define MKConvertInt16(V, D)         [MKConverter         getInt16:(V) or:(D)]
#define MKConvertUInt16(V, D)        [MKConverter        getUInt16:(V) or:(D)]
#define MKConvertInt32(V, D)         [MKConverter         getInt32:(V) or:(D)]
#define MKConvertUInt32(V, D)        [MKConverter        getUInt32:(V) or:(D)]
#define MKConvertInt64(V, D)         [MKConverter         getInt64:(V) or:(D)]
#define MKConvertUInt64(V, D)        [MKConverter        getUInt64:(V) or:(D)]

#define MKConvertInteger(V, D)         [MKConverter         getInteger:(V) or:(D)]
#define MKConvertUnsignedInteger(V, D) [MKConverter getUnsignedInteger:(V) or:(D)]

#define MKConvertDate(V, D)          [MKConverter getDate:(V) or:(D)]

NS_ASSUME_NONNULL_END
