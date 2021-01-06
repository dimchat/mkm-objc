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
//  MKMPrivateKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAsymmetricKey.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MKMPublicKey;

/*
 *  Asymmetric Cryptography Private Key
 *  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *
 *      key data format: {
 *          algorithm: "RSA", // ECC, ...
 *          data     : "{BASE64_ENCODE}",
 *          ...
 *      }
 */
@protocol MKMPrivateKey <MKMSignKey>

/**
 * Get public key from private key
 */
@property (readonly, strong, atomic) __kindof id<MKMPublicKey> publicKey;

@end

@interface MKMPrivateKey : MKMAsymmetricKey <MKMPrivateKey>

@end

#define MKMPrivateKeysEqual(key1, key2)                                        \
            [MKMPrivateKey privateKey:(key1) equals:(key2)]                    \
                                     /* EOF 'MKMPrivateKeysEqual(key1, key2)' */

#define MKMPrivateKeyWithAlgorithm(name)                                       \
            [MKMPrivateKey generate:(name)]                                    \
                                    /* EOF 'MKMPrivateKeyWithAlgorithm(name)' */

#define MKMPrivateKeyFromDictionary(keyInfo)                                   \
            [MKMPrivateKey parse:(keyInfo)]                                    \
                                /* EOF 'MKMPrivateKeyFromDictionary(keyInfo)' */

@protocol MKMPrivateKeyFactory <NSObject>

/**
 *  Generate key
 *
 * @return PrivateKey
 */
- (__kindof id<MKMPrivateKey>)generatePrivateKey;

/**
 *  Parse map object to key
 *
 * @param key - key info
 * @return PrivateKey
 */
- (nullable __kindof id<MKMPrivateKey>)parsePrivateKey:(NSDictionary *)key;

@end

@interface MKMPrivateKey (Creation)

+ (nullable id<MKMPrivateKeyFactory>)factoryForAlgorithm:(NSString *)algorithm;
+ (void)setFactory:(id<MKMPrivateKeyFactory>)factory forAlgorithm:(NSString *)algorithm;

+ (__kindof id<MKMPrivateKey>)generate:(NSString *)algorithm;

+ (nullable __kindof id<MKMPrivateKey>)parse:(NSDictionary *)key;

@end

NS_ASSUME_NONNULL_END
