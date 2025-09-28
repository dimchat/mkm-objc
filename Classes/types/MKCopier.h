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
//  MKCopier.h
//  MingKeMing
//
//  Created by Albert Moky on 2022/8/4.
//  Copyright © 2022 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCopier : NSObject

+ (id)copy:(id)object;
+ (id)deepCopy:(id)object;

+ (NSMutableDictionary<NSString *, id> *)copyMap:(NSDictionary<NSString *, id> *)dict;
+ (NSMutableDictionary<NSString *, id> *)deepCopyMap:(NSDictionary<NSString *, id> *)dict;

+ (NSMutableArray<id> *)copyList:(NSArray<id> *)array;
+ (NSMutableArray<id> *)deepCopyList:(NSArray<id> *)array;

@end

#pragma mark Shallow Copy

#define MKCopy(V)               [MKCopier copy:(V)]
#define MKCopyMap(D)            [MKCopier copyMap:(D)]
#define MKCopyList(A)           [MKCopier copyList:(A)]

#pragma mark Deep Copy

#define MKDeepCopy(V)           [MKCopier deepCopy:(V)]
#define MKDeepCopyMap(D)        [MKCopier deepCopyMap:(D)]
#define MKDeepCopyList(A)       [MKCopier deepCopyList:(A)]

NS_ASSUME_NONNULL_END
