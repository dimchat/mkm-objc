// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
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
//  MKDictionary.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKString;

/**
 *  Mapper
 *  ~~~~~~
 *  Map wrapper
 */
@protocol MKDictionary <NSObject, NSCopying>

/**
 * Get inner dictionary
 */
@property (readonly, strong, nonatomic) NSMutableDictionary<NSString *, id> *dictionary;

/**
 *  Copy inner dictionary
 */
- (NSMutableDictionary<NSString *, id> *)copyDictionary:(BOOL)deepCopy;

- (BOOL)isEqual:(id)object;
@property (readonly) NSUInteger hash;

- (NSEnumerator<NSString *> *)keyEnumerator;
- (NSEnumerator<id> *)objectEnumerator;

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(NSString *key, id obj, BOOL *stop))block;

@property (readonly, copy) NSArray<NSString *> *allKeys;

@property (readonly) NSUInteger count;

- (BOOL)isEmpty;  // count == 0

- (nullable id)objectForKey:(NSString *)aKey;
- (void)setObject:(id)anObject forKey:(NSString *)aKey;
- (void)removeObjectForKey:(NSString *)aKey;

/**
 *  Convenient getters
 */
- (nullable NSString *)stringForKey:(NSString *)aKey defaultValue:(nullable NSString *)aValue;
- (nullable NSNumber *)numberForKey:(NSString *)aKey defaultValue:(nullable NSNumber *)aValue;

- (BOOL)                 boolForKey:(NSString *)aKey defaultValue:(BOOL)aValue;

- (int)                   intForKey:(NSString *)aKey defaultValue:(int)aValue;
- (long)                 longForKey:(NSString *)aKey defaultValue:(long)aValue;
- (short)               shortForKey:(NSString *)aKey defaultValue:(short)aValue;
- (char)                 charForKey:(NSString *)aKey defaultValue:(char)aValue;

- (float)               floatForKey:(NSString *)aKey defaultValue:(float)aValue;
- (double)             doubleForKey:(NSString *)aKey defaultValue:(double)aValue;

- (unsigned int)         uintForKey:(NSString *)aKey defaultValue:(unsigned int)aValue;
- (unsigned long)       ulongForKey:(NSString *)aKey defaultValue:(unsigned long)aValue;
- (unsigned short)     ushortForKey:(NSString *)aKey defaultValue:(unsigned short)aValue;
- (unsigned char)       ucharForKey:(NSString *)aKey defaultValue:(unsigned char)aValue;

- (SInt8)                int8ForKey:(NSString *)aKey defaultValue:(SInt8)aValue;
- (UInt8)               uint8ForKey:(NSString *)aKey defaultValue:(UInt8)aValue;
- (SInt16)              int16ForKey:(NSString *)aKey defaultValue:(SInt16)aValue;
- (UInt16)             uint16ForKey:(NSString *)aKey defaultValue:(UInt16)aValue;
- (SInt32)              int32ForKey:(NSString *)aKey defaultValue:(SInt32)aValue;
- (UInt32)             uint32ForKey:(NSString *)aKey defaultValue:(UInt32)aValue;
- (SInt64)              int64ForKey:(NSString *)aKey defaultValue:(SInt64)aValue;
- (UInt64)             uint64ForKey:(NSString *)aKey defaultValue:(UInt64)aValue;

- (NSInteger)         integerForKey:(NSString *)aKey defaultValue:(NSInteger)aValue;
- (NSUInteger)unsignedIntegerForKey:(NSString *)aKey defaultValue:(NSUInteger)aValue;

- (nullable NSDate *)dateForKey:(NSString *)aKey defaultValue:(nullable NSDate *)aValue;
- (void)setDate:(NSDate *)date forKey:(NSString *)aKey;

- (void)setString:(id<MKString>)stringer forKey:(NSString *)aKey;
- (void)setDictionary:(id<MKDictionary>)mapper forKey:(NSString *)aKey;

@end

@interface MKDictionary : NSObject <MKDictionary>

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dict
NS_DESIGNATED_INITIALIZER;

- (instancetype)init
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCapacity:(NSUInteger)numItems
/* NS_DESIGNATED_INITIALIZER */;

@end

NS_ASSUME_NONNULL_END
