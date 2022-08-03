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
//  MKMCopier.m
//  MingKeMing
//
//  Created by Albert Moky on 2022/8/4.
//  Copyright © 2022 DIM Group. All rights reserved.
//

#import "MKMString.h"
#import "MKMDictionary.h"

#import "MKMCopier.h"

id MKMCopy(id obj) {
    /*
    if ([obj conformsToProtocol:@protocol(MKMString)]) {
        return [obj string];
    } else if ([obj conformsToProtocol:@protocol(MKMDictionary)]) {
        return MKMCopyMap([obj dictionary]);
    }
     */
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return MKMCopyMap(obj);
    } else if ([obj isKindOfClass:[NSArray class]]) {
        return MKMCopyList(obj);
    } else {
        return obj;
    }
}

NSMutableDictionary<NSString *, id> *MKMCopyMap(NSDictionary<NSString *, id> *dict) {
    NSMutableDictionary<NSString *, id> *mDict;
    mDict = [[NSMutableDictionary alloc] initWithCapacity:[dict count]];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [mDict setObject:obj forKey:key];
    }];
    return mDict;
}

NSMutableArray<id> *MKMCopyList(NSArray<id> *list) {
    NSMutableArray<id> *mArray;
    mArray = [[NSMutableArray alloc] initWithCapacity:[list count]];
    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [mArray addObject:obj];
    }];
    return mArray;
}

id MKMDeepCopy(id obj) {
    /*
    if ([obj conformsToProtocol:@protocol(MKMString)]) {
        return [obj string];
    } else if ([obj conformsToProtocol:@protocol(MKMDictionary)]) {
        return MKMDeepCopyMap([obj dictionary]);
    }
     */
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return MKMDeepCopyMap(obj);
    } else if ([obj isKindOfClass:[NSArray class]]) {
        return MKMDeepCopyList(obj);
    } else {
        return obj;
    }
}

NSMutableDictionary<NSString *, id> *MKMDeepCopyMap(NSDictionary<NSString *, id> *dict) {
    NSMutableDictionary<NSString *, id> *mDict;
    mDict = [[NSMutableDictionary alloc] initWithCapacity:[dict count]];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [mDict setObject:MKMDeepCopy(obj) forKey:key];
    }];
    return mDict;
}

NSMutableArray<id> *MKMDeepCopyList(NSArray<id> *list) {
    NSMutableArray<id> *mArray;
    mArray = [[NSMutableArray alloc] initWithCapacity:[list count]];
    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [mArray addObject:MKMDeepCopy(obj)];
    }];
    return mArray;
}
