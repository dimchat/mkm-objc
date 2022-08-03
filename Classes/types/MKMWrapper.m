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
//  MKMWrapper.m
//  MingKeMing
//
//  Created by Albert Moky on 2022/8/2.
//  Copyright © 2022 DIM Group. All rights reserved.
//

#import "MKMString.h"
#import "MKMDictionary.h"

#import "MKMWrapper.h"

NSString *MKMGetString(id str) {
    if ([str conformsToProtocol:@protocol(MKMString)]) {
        return [str string];
    }
    assert(!str || [str isKindOfClass:[NSString class]]);
    return str;
}

NSDictionary<NSString *, id> *MKMGetMap(id dict) {
    if ([dict conformsToProtocol:@protocol(MKMDictionary)]) {
        return [dict dictionary];
    }
    assert(!dict || [dict isKindOfClass:[NSDictionary class]]);
    return dict;
}

id MKMUnwrap(id obj) {
    if ([obj conformsToProtocol:@protocol(MKMString)]) {
        return [obj string];
    } else if ([obj conformsToProtocol:@protocol(MKMDictionary)]) {
        return MKMUnwrapMap([obj dictionary]);
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        return MKMUnwrapMap(obj);
    } else if ([obj isKindOfClass:[NSArray class]]) {
        return MKMUnwrapList(obj);
    } else {
        return obj;
    }
}

NSDictionary<NSString *, id> *MKMUnwrapMap(NSDictionary<NSString *, id> *dict) {
    NSMutableDictionary<NSString *, id> *mDict;
    mDict = [[NSMutableDictionary alloc] initWithCapacity:[dict count]];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        id naked = MKMUnwrap(obj);
        [mDict setObject:naked forKey:key];
    }];
    return mDict;
}

NSArray<id> *MKMUnwrapList(NSArray<id> *list) {
    NSMutableArray<id> *mArray;
    mArray = [[NSMutableArray alloc] initWithCapacity:[list count]];
    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id naked = MKMUnwrap(obj);
        [mArray addObject:naked];
    }];
    return mArray;
}
