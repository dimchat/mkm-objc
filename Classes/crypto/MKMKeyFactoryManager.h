// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  MKMKeyFactoryManager.h
//  MingKeMing
//
//  Created by Albert Moky on 2023/1/31.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <MingKeMing/MKMSymmetricKey.h>
#import <MingKeMing/MKMPrivateKey.h>
#import <MingKeMing/MKMPublicKey.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  General Factory for Crypto Keys
 *  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 */
@protocol MKMGeneralKeyFactory <NSObject>

/**
 * Get key algorithm
 */
- (nullable NSString *)algorithm:(NSDictionary<NSString *, id> *)keyInfo;

/**
 * Try to verify with signature
 */
- (BOOL)isSignKey:(id<MKMSignKey>)sKey matchVerifyKey:(id<MKMVerifyKey>)pKey;

/**
 * Try to verify with encryption
 */
- (BOOL)isEncryptKey:(id<MKMEncryptKey>)pKey matchDecryptKey:(id<MKMDecryptKey>)sKey;

#pragma mark SymmetricKey

- (void)setSymmetricKeyFactory:(id<MKMSymmetricKeyFactory>)factory
                  forAlgorithm:(NSString *)algorithm;
- (nullable id<MKMSymmetricKeyFactory>)symmetricKeyFactoryForAlgorithm:(NSString *)algorithm;

- (nullable id<MKMSymmetricKey>)generateSymmetricKeyWithAlgorithm:(NSString *)algorithm;
- (nullable id<MKMSymmetricKey>)parseSymmetricKey:(id)key;

#pragma mark PrivateKey

- (void)setPrivateKeyFactory:(id<MKMPrivateKeyFactory>)factory
                forAlgorithm:(NSString *)algorithm;
- (nullable id<MKMPrivateKeyFactory>)privateKeyFactoryForAlgorithm:(NSString *)algorithm;

- (nullable id<MKMPrivateKey>)generatePrivateKeyWithAlgorithm:(NSString *)algorithm;
- (nullable id<MKMPrivateKey>)parsePrivateKey:(id)key;

#pragma mark PublicKey

- (void)setPublicKeyFactory:(id<MKMPublicKeyFactory>)factory
               forAlgorithm:(NSString *)algorithm;
- (nullable id<MKMPublicKeyFactory>)publicKeyFactoryForAlgorithm:(NSString *)algorithm;

- (nullable id<MKMPublicKey>)parsePublicKey:(id)key;

@end

#pragma mark -

@interface MKMGeneralKeyFactory : NSObject <MKMGeneralKeyFactory>

@end

@interface MKMKeyFactoryManager : NSObject

@property(strong, nonatomic) id<MKMGeneralKeyFactory> generalFactory;

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
