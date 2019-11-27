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
//  MKMCryptographyKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MKMCryptographyKey <NSObject>

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

@end

@protocol MKMSymmetricKey <MKMEncryptKey, MKMDecryptKey>

@end

@protocol MKMAsymmetricKey <MKMCryptographyKey>

@end

@protocol MKMSignKey <MKMAsymmetricKey>

/**
 *  signature = sign(data, SK);
 */
- (NSData *)sign:(NSData *)data;

@end

@protocol MKMVerifyKey <MKMAsymmetricKey>

/**
 *  OK = verify(data, signature, PK)
 */
- (BOOL)verify:(NSData *)data withSignature:(NSData *)signature;

@end

#pragma mark -

/*
 *  Cryptography Key
 *
 *      keyInfo format: {
 *          algorithm: "RSA", // ECC, AES, ...
 *          data     : "{BASE64_ENCODE}",
 *          ...
 *      }
 */
@interface MKMCryptographyKey : MKMDictionary <MKMCryptographyKey> {
    
    // key data, set by subclass
    NSData *_data;
}

- (instancetype)initWithDictionary:(NSDictionary *)keyInfo
NS_DESIGNATED_INITIALIZER;

@end

@interface MKMCryptographyKey (Runtime)

+ (void)registerClass:(nullable Class)keyClass forAlgorithm:(NSString *)name;

+ (nullable instancetype)getInstance:(id)key;

@end

@interface MKMCryptographyKey (PersistentStore)

+ (nullable instancetype)loadKeyWithIdentifier:(NSString *)identifier;

- (BOOL)saveKeyWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
