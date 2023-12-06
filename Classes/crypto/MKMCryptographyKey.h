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

#import <MingKeMing/MKMDictionary.h>

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
 *  1. Symmetric Key:
 *     ciphertext = encrypt(plaintext, PW)
 *  2. Asymmetric Public Key:
 *     ciphertext = encrypt(plaintext, PK)
 *
 * @param plaintext - plain data
 * @param extra     - store extra variables ('IV' for 'AES')
 * @return ciphertext
 */
- (NSData *)encrypt:(NSData *)plaintext params:(nullable NSMutableDictionary<NSString *, id> *)extra;

@end

@protocol MKMDecryptKey <MKMCryptographyKey>

/**
 *  1. Symmetric Key:
 *     plaintext = decrypt(ciphertext, PW);
 *  2. Asymmetric Private Key:
 *     plaintext = decrypt(ciphertext, SK);
 *
 * @param ciphertext - encrypted data
 * @param extra      - extra params ('IV' for 'AES')
 * @return plaintext
 */
- (nullable NSData *)decrypt:(NSData *)ciphertext params:(nullable NSDictionary<NSString *, id> *)extra;

/**
 *  OK = decrypt(encrypt(data, SK), PK) == data
 */
- (BOOL)matchEncryptKey:(id<MKMEncryptKey>)pKey;

@end

NS_ASSUME_NONNULL_END
