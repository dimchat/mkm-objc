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
//  MKMDictionary.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMCopier.h"
#import "MKMString.h"

#import "MKMDictionary.h"

@interface MKMDictionary () {
    
    // inner dictionary
    NSMutableDictionary<NSString *, id> *_storeDictionary;
}

@end

@implementation MKMDictionary

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        if ([dict isKindOfClass:[NSMutableDictionary class]]) {
            _storeDictionary = (NSMutableDictionary *)dict;
        } else {
            _storeDictionary = [dict mutableCopy];
        }
    }
    return self;
}

/* designated initializer */
- (instancetype)init {
    if (self = [super init]) {
        _storeDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    if (self = [self init]) {
        _storeDictionary = [[NSMutableDictionary alloc] initWithCapacity:numItems];
    }
    return self;
}

- (instancetype)initWithObjects:(const id _Nonnull [_Nullable])objects
                        forKeys:(const id <NSCopying> _Nonnull [_Nullable])keys
                          count:(NSUInteger)cnt {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:objects
                                                       forKeys:keys
                                                         count:cnt];
    return [self initWithDictionary:dict];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSDictionary *dict = [[NSDictionary alloc] initWithCoder:aDecoder];
    return [self initWithDictionary:dict];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    id dict = [[self class] allocWithZone:zone];
    dict = [dict initWithDictionary:_storeDictionary];
    return dict;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if ([object conformsToProtocol:@protocol(MKMDictionary)]) {
        object = [object dictionary];
    }
    return [_storeDictionary isEqualToDictionary:object];
}

- (NSUInteger)count {
    return [_storeDictionary count];
}

- (NSEnumerator *)keyEnumerator {
    return [_storeDictionary keyEnumerator];
}

- (NSEnumerator *)objectEnumerator {
    return [_storeDictionary objectEnumerator];
}

#pragma mark -

- (NSMutableDictionary *)dictionary {
    return _storeDictionary;
}

- (NSMutableDictionary *)dictionary:(BOOL)deepCopy {
    if (deepCopy) {
        return MKMDeepCopyMap(_storeDictionary);
    } else {
        return MKMCopyMap(_storeDictionary);
    }
}

- (id)objectForKey:(NSString *)aKey {
    id object = [_storeDictionary objectForKey:aKey];
    if (object == [NSNull null]) {
        return nil;
    }
    return object;
}

- (void)removeObjectForKey:(NSString *)aKey {
    [_storeDictionary removeObjectForKey:aKey];
}

- (void)setObject:(id)anObject forKey:(NSString *)aKey {
    if (anObject) {
        [_storeDictionary setObject:anObject forKey:aKey];
    } else {
        [_storeDictionary removeObjectForKey:aKey];
    }
}

#pragma mark - Convenient getters

- (NSString *)stringForKey:(NSString *)aKey {
    return [self objectForKey:aKey];
}

- (BOOL)boolForKey:(NSString *)aKey {
    id value = [self objectForKey:aKey];
    return [value boolValue];
}

- (int)intForKey:(NSString *)aKey {
    NSNumber *value = [self objectForKey:aKey];
    return [value intValue];
}

- (long)longForKey:(NSString *)aKey {
    NSNumber *value = [self objectForKey:aKey];
    return [value longValue];
}

- (char)charForKey:(NSString *)aKey {
    NSNumber *value = [self objectForKey:aKey];
    return [value charValue];
}

- (short)shortForKey:(NSString *)aKey {
    NSNumber *value = [self objectForKey:aKey];
    return [value shortValue];
}

- (float)floatForKey:(NSString *)aKey {
    NSNumber *value = [self objectForKey:aKey];
    return [value floatValue];
}

- (double)doubleForKey:(NSString *)aKey {
    NSNumber *value = [self objectForKey:aKey];
    return [value doubleValue];
}

- (NSDate *)dateForKey:(NSString *)aKey {
    NSNumber *timestamp = [self objectForKey:aKey];
    if (!timestamp) {
        //NSAssert(false, @"message time not found: %@", env);
        return nil;
    }
    return [[NSDate alloc] initWithTimeIntervalSince1970:[timestamp doubleValue]];
}

- (void)setDate:(NSDate *)date forKey:(NSString *)aKey {
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    [_storeDictionary setObject:@(timestamp) forKey:aKey];
}

- (void)setString:(id<MKMString>)stringer forKey:(NSString *)aKey {
    [_storeDictionary setObject:[stringer string] forKey:aKey];
}

- (void)setDictionary:(id<MKMDictionary>)mapper forKey:(NSString *)aKey {
    [_storeDictionary setObject:[mapper dictionary] forKey:aKey];
}

@end
