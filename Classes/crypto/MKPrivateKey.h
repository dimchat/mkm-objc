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
//  MKPrivateKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <MingKeMing/MKAsymmetricKey.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKPublicKey;

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
@protocol MKPrivateKey <MKSignKey>

/**
 * Get public key from private key
 */
@property (readonly, strong, nonatomic) id<MKPublicKey> publicKey;

@end

#pragma mark - Key Factory

@protocol MKPrivateKeyFactory <NSObject>

/**
 *  Generate key
 *
 * @return PrivateKey
 */
- (id<MKPrivateKey>)generatePrivateKey;

/**
 *  Parse map object to key
 *
 * @param key - key info
 * @return PrivateKey
 */
- (nullable id<MKPrivateKey>)parsePrivateKey:(NSDictionary *)key;

@end

#pragma mark - Factory methods

#ifdef __cplusplus
extern "C" {
#endif

_Nullable id<MKPrivateKeyFactory> MKPrivateKeyGetFactory(NSString *algorithm);
void MKPrivateKeySetFactory(NSString *algorithm, id<MKPrivateKeyFactory> factory);

_Nullable id<MKPrivateKey> MKPrivateKeyGenerate(NSString *algorithm);

_Nullable id<MKPrivateKey> MKPrivateKeyParse(_Nullable id key);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
