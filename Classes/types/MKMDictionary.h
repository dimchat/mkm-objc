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
//  MKMDictionary.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKMString;

/**
 *  Mapper
 *  ~~~~~~
 *  Map wrapper
 */
@protocol MKMDictionary <NSObject, NSCopying>

/**
 * Get inner dictionary
 */
@property (readonly, strong, nonatomic) NSMutableDictionary<NSString *, id> *dictionary;

/**
 *  Copy inner dictionary
 */
- (NSMutableDictionary<NSString *, id> *)dictionary:(BOOL)deepCopy;

//- (BOOL)isEqual:(id)object;
//@property (readonly) NSUInteger hash;

- (NSEnumerator *)keyEnumerator;
- (NSEnumerator *)objectEnumerator;
- (NSUInteger)count;

- (BOOL)isEmpty;  // count == 0

- (id)objectForKey:(NSString *)aKey;
- (void)setObject:(id)anObject forKey:(NSString *)aKey;
- (void)removeObjectForKey:(NSString *)aKey;

/**
 *  Convenient getters
 */
- (nullable NSString *)stringForKey:(NSString *)aKey defaultValue:(nullable NSString *)aValue;
- (BOOL)                 boolForKey:(NSString *)aKey defaultValue:(BOOL)aValue;

- (int)                   intForKey:(NSString *)aKey defaultValue:(int)aValue;
- (long)                 longForKey:(NSString *)aKey defaultValue:(long)aValue;
- (char)                 charForKey:(NSString *)aKey defaultValue:(char)aValue;
- (short)               shortForKey:(NSString *)aKey defaultValue:(short)aValue;
- (float)               floatForKey:(NSString *)aKey defaultValue:(float)aValue;
- (double)             doubleForKey:(NSString *)aKey defaultValue:(double)aValue;

- (unsigned int)         uintForKey:(NSString *)aKey defaultValue:(unsigned int)aValue;
- (unsigned long)       ulongForKey:(NSString *)aKey defaultValue:(unsigned long)aValue;
- (unsigned short)     ushortForKey:(NSString *)aKey defaultValue:(unsigned short)aValue;

- (SInt8)                int8ForKey:(NSString *)aKey defaultValue:(SInt8)aValue;
- (UInt8)               uint8ForKey:(NSString *)aKey defaultValue:(UInt8)aValue;
- (SInt16)              int16ForKey:(NSString *)aKey defaultValue:(SInt16)aValue;
- (UInt16)             uint16ForKey:(NSString *)aKey defaultValue:(UInt16)aValue;
- (NSInteger)         integerForKey:(NSString *)aKey defaultValue:(NSInteger)aValue;
- (NSUInteger)unsignedIntegerForKey:(NSString *)aKey defaultValue:(NSUInteger)aValue;

- (nullable NSDate *)dateForKey:(NSString *)aKey defaultValue:(nullable NSDate *)aValue;
- (void)setDate:(NSDate *)date forKey:(NSString *)aKey;

- (void)setString:(id<MKMString>)stringer forKey:(NSString *)aKey;
- (void)setDictionary:(id<MKMDictionary>)mapper forKey:(NSString *)aKey;

@end

@interface MKMDictionary : NSDictionary<NSString *, id> <MKMDictionary>

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dict
NS_DESIGNATED_INITIALIZER;

- (instancetype)init
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCapacity:(NSUInteger)numItems
/* NS_DESIGNATED_INITIALIZER */;

@end

NS_ASSUME_NONNULL_END
