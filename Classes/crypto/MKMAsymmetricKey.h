// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
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
//  MKMAsymmetricKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMCryptographyKey.h"

NS_ASSUME_NONNULL_BEGIN

#define ACAlgorithmRSA @"RSA"
#define ACAlgorithmECC @"ECC"

@protocol MKMPrivateKey;

@protocol MKMPublicKey <MKMVerifyKey>

/**
 * Check whether paired
 */
- (BOOL)isMatch:(id<MKMSignKey>)SK;

@end

@protocol MKMPrivateKey <MKMSignKey>

/**
 * Get public key from private key
 */
@property (readonly, atomic, nullable) __kindof id<MKMPublicKey> publicKey;

@end

/*
 *  Asymmetric Cryptography Key
 *
 *      keyInfo format: {
 *          algorithm: "RSA", // ECC, ...
 *          data     : "{BASE64_ENCODE}",
 *          ...
 *      }
 */
@interface MKMAsymmetricKey : MKMCryptographyKey <MKMAsymmetricKey>

@end

NS_ASSUME_NONNULL_END
