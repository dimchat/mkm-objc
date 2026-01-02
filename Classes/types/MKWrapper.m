// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2022 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2022 Albert Moky
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
//  MKWrapper.m
//  MingKeMing
//
//  Created by Albert Moky on 2022/8/2.
//  Copyright © 2022 DIM Group. All rights reserved.
//

#import "MKString.h"
#import "MKDictionary.h"

#import "MKWrapper.h"

@implementation MKWrapper

static id<MKWrapper> s_wrapper = nil;

+ (id<MKWrapper>)getWrapper {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!s_wrapper) {
            s_wrapper = [[MKDataWrapper alloc] init];
        }
    });
    return s_wrapper;
}

+ (void)setWrapper:(id<MKWrapper>)wrapper {
    s_wrapper = wrapper;
}

//
//  Data Wrap Interface
//

+ (nullable NSString *)getString:(nullable id)str {
    id<MKWrapper> wrapper = [self getWrapper];
    return [wrapper getString:str];
}

+ (nullable NSDictionary *)getMap:(nullable id)dict {
    id<MKWrapper> wrapper = [self getWrapper];
    return [wrapper getMap:dict];
}

+ (nullable id)unwrap:(nullable id)object {
    id<MKWrapper> wrapper = [self getWrapper];
    return [wrapper unwrap:object];
}

+ (NSMutableDictionary<NSString *, id> *)unwrapMap:(NSDictionary <NSString *, id> *)dict {
    id<MKWrapper> wrapper = [self getWrapper];
    return [wrapper unwrapMap:dict];
}

+ (NSMutableArray<id> *)unwrapList:(NSArray<id> *)array {
    id<MKWrapper> wrapper = [self getWrapper];
    return [wrapper unwrapList:array];
}

@end

#pragma mark - Base Wrapper

@implementation MKDataWrapper

// Override
- (nullable NSString *)getString:(nullable id)str {
    if (str == nil) {
        return nil;
    } else if ([str conformsToProtocol:@protocol(MKString)]) {
        return [str string];
    } else if ([str isKindOfClass:[NSString class]]) {
        return str;
    } else {
        NSAssert(false, @"not a string: '%@'", str);
        return [NSString stringWithFormat:@"%@", str];
    }
}

// Override
- (nullable __kindof NSDictionary *)getMap:(nullable id)dict {
    if (dict == nil) {
        return nil;
    } else if ([dict conformsToProtocol:@protocol(MKDictionary)]) {
        return [dict dictionary];
    } else if ([dict isKindOfClass:[NSDictionary class]]) {
        return dict;
    } else {
        NSAssert(false, @"not a dictionary: '%@'", dict);
        return nil;
    }
}

// Override
- (nullable id)unwrap:(nullable id)object {
    if (object == nil) {
        return nil;
    } else if ([object conformsToProtocol:@protocol(MKString)]) {
        return [object string];
    } else if ([object conformsToProtocol:@protocol(MKDictionary)]) {
        return [self unwrapMap:[object dictionary]];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        return [self unwrapMap:object];
    } else if ([object isKindOfClass:[NSArray class]]) {
        return [self unwrapList:object];
    } else {
        return object;
    }
}

// Override
- (NSMutableDictionary<NSString *, id> *)unwrapMap:(NSDictionary <NSString *, id> *)dict {
    NSMutableDictionary<NSString *, id> *mDict;
    mDict = [[NSMutableDictionary alloc] initWithCapacity:[dict count]];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [mDict setObject:[self unwrap:obj] forKey:key];
    }];
    return mDict;
}

// Override
- (NSMutableArray<id> *)unwrapList:(NSArray<id> *)array {
    NSMutableArray<id> *mArray;
    mArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [mArray addObject:[self unwrap:obj]];
    }];
    return mArray;
}

@end
