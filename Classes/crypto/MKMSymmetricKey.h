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
//  MKMSymmetricKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMCryptographyKey.h"

NS_ASSUME_NONNULL_BEGIN

/*
 *  Symmetric Cryptography Key
 *
 *      keyInfo format: {
 *          algorithm: "AES", // DES, ...
 *          data     : "{BASE64_ENCODE}",
 *          ...
 *      }
 */
@protocol MKMSymmetricKey <MKMEncryptKey, MKMDecryptKey>

@end

#define SCAlgorithmAES @"AES"
#define SCAlgorithmDES @"DES"

@interface MKMSymmetricKey : MKMCryptographyKey <MKMSymmetricKey>

+ (BOOL)symmetricKey:(id<MKMSymmetricKey>)key1 equals:(id<MKMSymmetricKey>)key2;

@end

#define MKMSymmetricKeysEqual(key1, key2)                                      \
            [MKMSymmetricKey symmetricKey:(key1) equals:(key2)]                \
                                   /* EOF 'MKMSymmetricKeysEqual(key1, key2)' */

#define MKMSymmetricKeyWithAlgorithm(name)                                     \
            [MKMSymmetricKey generate:(name)]                                  \
                                  /* EOF 'MKMSymmetricKeyWithAlgorithm(name)' */

#define MKMSymmetricKeyFromDictionary(key)                                     \
            [MKMSymmetricKey parse:(key)]                                      \
                                  /* EOF 'MKMSymmetricKeyFromDictionary(key)' */

#pragma mark - Creation

@protocol MKMSymmetricKeyFactory <NSObject>

- (nullable __kindof id<MKMSymmetricKey>)generateSymmetricKey:(NSString *)algorithm;

- (nullable __kindof id<MKMSymmetricKey>)parseSymmetricKey:(NSDictionary *)key;

@end

@interface MKMSymmetricKey (Creation)

+ (void)setFactory:(id<MKMSymmetricKeyFactory>)factory;

+ (nullable __kindof id<MKMSymmetricKey>)generate:(NSString *)algorithm;

+ (nullable __kindof id<MKMSymmetricKey>)parse:(NSDictionary *)key;

@end

NS_ASSUME_NONNULL_END
