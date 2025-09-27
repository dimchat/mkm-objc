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

- (nullable NSString *)getString:(id)value defaultValue:(nullable NSString *)defaultValue;

- (nullable NSNumber *)getNumber:(id)value defaultValue:(nullable NSNumber *)defaultValue;

- (BOOL)getBool:(id)value     defaultValue:(BOOL)defaultValue;

- (int)getInt:(id)value       defaultValue:(int)defaultValue;
- (long)getLong:(id)value     defaultValue:(long)defaultValue;
- (short)getShort:(id)value   defaultValue:(short)defaultValue;
- (char)getChar:(id)value     defaultValue:(char)defaultValue;

- (float)getFloat:(id)value   defaultValue:(float)defaultValue;
- (double)getDouble:(id)value defaultValue:(double)defaultValue;

- (unsigned int)getUnsignedInt:(id)value     defaultValue:(unsigned int)defaultValue;
- (unsigned long)getUnsignedLong:(id)value   defaultValue:(unsigned long)defaultValue;
- (unsigned short)getUnsignedShort:(id)value defaultValue:(unsigned short)defaultValue;
- (unsigned char)getUnsignedChar:(id)value   defaultValue:(unsigned char)defaultValue;

- (NSInteger)getInteger:(id)value          defaultValue:(NSInteger)defaultValue;
- (NSUInteger)getUnsignedInteger:(id)value defaultValue:(NSUInteger)defaultValue;

- (nullable NSDate *)getDate:(id)value defaultValue:(nullable NSDate *)defaultValue;

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

+ (nullable NSString *)getString:(id)value defaultValue:(nullable NSString *)defaultValue;

+ (nullable NSNumber *)getNumber:(id)value defaultValue:(nullable NSNumber *)defaultValue;

+ (BOOL)getBool:(id)value     defaultValue:(BOOL)defaultValue;

+ (int)getInt:(id)value       defaultValue:(int)defaultValue;
+ (long)getLong:(id)value     defaultValue:(long)defaultValue;
+ (short)getShort:(id)value   defaultValue:(short)defaultValue;
+ (char)getChar:(id)value     defaultValue:(char)defaultValue;

+ (float)getFloat:(id)value   defaultValue:(float)defaultValue;
+ (double)getDouble:(id)value defaultValue:(double)defaultValue;

+ (unsigned int)getUnsignedInt:(id)value     defaultValue:(unsigned int)defaultValue;
+ (unsigned long)getUnsignedLong:(id)value   defaultValue:(unsigned long)defaultValue;
+ (unsigned short)getUnsignedShort:(id)value defaultValue:(unsigned short)defaultValue;
+ (unsigned char)getUnsignedChar:(id)value   defaultValue:(unsigned char)defaultValue;

+ (NSInteger)getInteger:(id)value          defaultValue:(NSInteger)defaultValue;
+ (NSUInteger)getUnsignedInteger:(id)value defaultValue:(NSUInteger)defaultValue;

+ (nullable NSDate *)getDate:(id)value defaultValue:(nullable NSDate *)defaultValue;

@end

#pragma mark - Data Converter

/**
 *  Base Converter
 */
@interface MKDataConverter : NSObject<MKConverter>

@end

NS_ASSUME_NONNULL_END
