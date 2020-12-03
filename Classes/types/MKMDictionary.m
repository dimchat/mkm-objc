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

- (id)copyWithZone:(NSZone *)zone {
    id dict = [[self class] allocWithZone:zone];
    dict = [dict initWithDictionary:_storeDictionary];
    return dict;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if ([object conformsToProtocol:@protocol(MKMDictionary)]) {
        return [_storeDictionary isEqualToDictionary:[object dictionary]];
    }
    if ([object isKindOfClass:[NSDictionary class]]) {
        return [_storeDictionary isEqualToDictionary:object];
    }
    return NO;
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
    // TODO: implement deep copy
    return [_storeDictionary mutableCopy];
}

- (id)objectForKey:(NSString *)aKey {
    return [_storeDictionary objectForKey:aKey];
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

@end
