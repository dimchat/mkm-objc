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
//  MKWrapper.h
//  MingKeMing
//
//  Created by Albert Moky on 2022/8/2.
//  Copyright © 2022 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKWrapper : NSObject

/**
 *  Get inner String
 *  ~~~~~~~~~~~~~~~~
 *  Remove first wrapper
 */
+ (nullable NSString *)getString:(nullable id)string;

/**
 *  Get inner Map
 *  ~~~~~~~~~~~~~
 *  Remove first wrapper
 */
+ (nullable __kindof NSDictionary *)getMap:(nullable id)dict;

#pragma mark Recursively

/**
 *  Unwrap recursively
 *  ~~~~~~~~~~~~~~~~~~
 *  Remove all wrappers
 */
+ (nullable id)unwrap:(nullable id)object;

/**
 *  Unwrap values for keys in map
 */
+ (NSMutableDictionary<NSString *, id> *)unwrapMap:(NSDictionary <NSString *, id> *)dict;

/**
 *  Unwrap values in the array
 */
+ (NSMutableArray<id> *)unwrapList:(NSArray<id> *)array;

@end

#pragma mark - Conveniences

#define MKGetString(S)          [MKWrapper getString:(S)]
#define MKGetMap(D)             [MKWrapper getMap:(D)]

#define MKUnwrap(object)        [MKWrapper unwrap:(object)]
#define MKUnwrapMap(dict)       [MKWrapper unwrapMap:(dict)]
#define MKUnwrapList(array)     [MKWrapper unwrapList:(array)]

NS_ASSUME_NONNULL_END
