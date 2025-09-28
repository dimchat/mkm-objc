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
//  MKCopier.m
//  MingKeMing
//
//  Created by Albert Moky on 2022/8/4.
//  Copyright © 2022 DIM Group. All rights reserved.
//

#import "MKMString.h"
#import "MKMDictionary.h"

#import "MKCopier.h"

@implementation MKCopier

+ (id)copy:(id)object {
    if ([object conformsToProtocol:@protocol(MKMString)]) {
        return [object string];
    } else if ([object conformsToProtocol:@protocol(MKMDictionary)]) {
        object = [object dictionary];
        return [self copyMap:object];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        return [self copyMap:object];
    } else if ([object isKindOfClass:[NSArray class]]) {
        return [self copyList:object];
    } else {
        return object;
    }
}

+ (id)deepCopy:(id)object {
    if ([object conformsToProtocol:@protocol(MKMString)]) {
        return [object string];
    } else if ([object conformsToProtocol:@protocol(MKMDictionary)]) {
        object = [object dictionary];
        return [self deepCopyMap:object];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        return [self deepCopyMap:object];
    } else if ([object isKindOfClass:[NSArray class]]) {
        return [self deepCopyList:object];
    } else {
        return object;
    }
}

+ (NSMutableDictionary<NSString *, id> *)copyMap:(NSDictionary<NSString *, id> *)dict {
    NSMutableDictionary<NSString *, id> *mDict;
    mDict = [[NSMutableDictionary alloc] initWithCapacity:[dict count]];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [mDict setObject:obj forKey:key];
    }];
    return mDict;
}

+ (NSMutableDictionary<NSString *, id> *)deepCopyMap:(NSDictionary<NSString *, id> *)dict {
    NSMutableDictionary<NSString *, id> *mDict;
    mDict = [[NSMutableDictionary alloc] initWithCapacity:[dict count]];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [mDict setObject:[self deepCopy:obj] forKey:key];
    }];
    return mDict;
}

+ (NSMutableArray<id> *)copyList:(NSArray<id> *)array {
    NSMutableArray<id> *mArray;
    mArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [mArray addObject:obj];
    }];
    return mArray;
}

+ (NSMutableArray<id> *)deepCopyList:(NSArray<id> *)array {
    NSMutableArray<id> *mArray;
    mArray = [[NSMutableArray alloc] initWithCapacity:[array count]];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [mArray addObject:[self deepCopy:obj]];
    }];
    return mArray;
}

@end
