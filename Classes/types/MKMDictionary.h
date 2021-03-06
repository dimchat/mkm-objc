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

@protocol MKMDictionary <NSObject, NSCopying>

/**
 * Get inner dictionary
 */
@property (readonly, strong, nonatomic) NSMutableDictionary<NSString *, id> *dictionary;

/**
 *  Copy inner dictionary
 */
- (NSMutableDictionary<NSString *, id> *)dictionary:(BOOL)deepCopy;

- (id)objectForKey:(NSString *)aKey;
- (void)setObject:(id)anObject forKey:(NSString *)aKey;
- (void)removeObjectForKey:(NSString *)aKey;

@end

@interface MKMDictionary : NSDictionary<NSString *, id> <MKMDictionary>

- (instancetype)initWithDictionary:(NSDictionary<NSString *, id> *)dict
NS_DESIGNATED_INITIALIZER;

- (instancetype)init
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCapacity:(NSUInteger)numItems
/* NS_DESIGNATED_INITIALIZER */;

- (NSUInteger)count;

- (NSEnumerator *)keyEnumerator;
- (NSEnumerator *)objectEnumerator;

@end

@interface MKMDictionary (Copy)

+ (NSMutableDictionary *)copy:(NSDictionary *)dict circularly:(BOOL)deepCopy;

@end

NS_ASSUME_NONNULL_END
