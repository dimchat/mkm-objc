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
//  MKMCryptographyKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

/*
 *  Cryptography Key
 *  ~~~~~~~~~~~~~~~~
 *  Cryptography key with designated algorithm
 *
 *  key data format: {
 *      algorithm : "RSA", // ECC, AES, ...
 *      data      : "{BASE64_ENCODE}",
 *      ...
 *  }
 */
@protocol MKMCryptographyKey <MKMDictionary>

@property (readonly, strong, nonatomic) NSString *algorithm;
@property (readonly, strong, nonatomic) NSData *data;

@end

@protocol MKMEncryptKey <MKMCryptographyKey>

/**
 *  CT = encrypt(text, PW)
 *  CT = encrypt(text, PK)
 */
- (NSData *)encrypt:(NSData *)plaintext;

@end

@protocol MKMDecryptKey <MKMCryptographyKey>

/**
 *  text = decrypt(CT, PW);
 *  text = decrypt(CT, SK);
 */
- (nullable NSData *)decrypt:(NSData *)ciphertext;

/**
 *  OK = decrypt(encrypt(data, SK), PK) == data
 */
- (BOOL)isMatch:(id<MKMEncryptKey>)pKey;

@end

#pragma mark -

@interface MKMCryptographyKey : MKMDictionary <MKMCryptographyKey>

/**
 *  Get key algorithm name
 *
 * @return algorithm name
 */
+ (NSString *)algorithm:(NSDictionary *)key;

/**
 *  Check keys by encryption
 */
+ (BOOL)decryptKey:(id<MKMDecryptKey>)sKey isMatch:(id<MKMEncryptKey>)pKey;

@end

#define MKMCryptographyKeyAlgorithm(keyInfo)                                   \
            [MKMCryptographyKey algorithm:(keyInfo)]                           \
                                 /* EOF 'MKMCryptographyKeyAlgorithm(keyInfo) */

#define MKMCryptographyKeysMatch(sKey, pKey)                                   \
            [MKMCryptographyKey decryptKey:(sKey) isMatch:(pKey)]              \
                    /* EOF 'MKMCryptographyKeysMatch(encryptKey, decryptKey)' */

NS_ASSUME_NONNULL_END
