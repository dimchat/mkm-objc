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

#import <MingKeMing/MKMCryptographyKey.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  Symmetric Cryptography Key
 *  ~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  This class is used to encrypt or decrypt message data
 *
 *  keyInfo format: {
 *      algorithm: "AES", // DES, ...
 *      data     : "{BASE64_ENCODE}",
 *      ...
 *  }
 */
@protocol MKMSymmetricKey <MKMEncryptKey, MKMDecryptKey>

@end

#define MKMAlgorithm_AES @"AES"
#define MKMAlgorithm_DES @"DES"

#pragma mark - Key Factory

@protocol MKMSymmetricKeyFactory <NSObject>

/**
 *  Generate key
 *
 * @return SymmetricKey
 */
- (id<MKMSymmetricKey>)generateSymmetricKey;

/**
 *  Parse map object to key
 *
 * @param key - key info
 * @return SymmetricKey
 */
- (nullable id<MKMSymmetricKey>)parseSymmetricKey:(NSDictionary *)key;

@end

#ifdef __cplusplus
extern "C" {
#endif

_Nullable id<MKMSymmetricKeyFactory> MKMSymmetricKeyGetFactory(NSString *algorithm);
void MKMSymmetricKeySetFactory(NSString *algorithm, id<MKMSymmetricKeyFactory> factory);

_Nullable id<MKMSymmetricKey> MKMSymmetricKeyGenerate(NSString *algorithm);
_Nullable id<MKMSymmetricKey> MKMSymmetricKeyParse(_Nullable id key);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
