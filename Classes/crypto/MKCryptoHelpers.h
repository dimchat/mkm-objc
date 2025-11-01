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
//  MKCryptoHelpers.h
//  MingKeMing
//
//  Created by Albert Moky on 2023/1/31.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKSymmetricKey;
@protocol MKSymmetricKeyFactory;

@protocol MKPublicKey;
@protocol MKPublicKeyFactory;

@protocol MKPrivateKey;
@protocol MKPrivateKeyFactory;

@protocol MKSymmetricKeyHelper <NSObject>

- (void)setSymmetricKeyFactory:(id<MKSymmetricKeyFactory>)factory
                     algorithm:(NSString *)name;
- (nullable id<MKSymmetricKeyFactory>)getSymmetricKeyFactory:(NSString *)algorithm;

- (nullable id<MKSymmetricKey>)generateSymmetricKey:(NSString *)algorithm;

- (nullable id<MKSymmetricKey>)parseSymmetricKey:(nullable id)key;

@end

@protocol MKPublicKeyHelper <NSObject>

- (void)setPublicKeyFactory:(id<MKPublicKeyFactory>)factory
                  algorithm:(NSString *)name;
- (nullable id<MKPublicKeyFactory>)getPublicKeyFactory:(NSString *)algorithm;

- (nullable id<MKPublicKey>)parsePublicKey:(nullable id)key;

@end

@protocol MKPrivateKeyHelper <NSObject>

- (void)setPrivateKeyFactory:(id<MKPrivateKeyFactory>)factory
                   algorithm:(NSString *)name;
- (nullable id<MKPrivateKeyFactory>)getPrivateKeyFactory:(NSString *)algorithm;

- (nullable id<MKPrivateKey>)generatePrivateKey:(NSString *)algorithm;

- (nullable id<MKPrivateKey>)parsePrivateKey:(nullable id)key;

@end

#pragma mark - CryptographyKey FactoryManager

@interface MKCryptoExtensions : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic, nullable) id<MKSymmetricKeyHelper> symmetricHelper;

@property (strong, nonatomic, nullable) id<MKPrivateKeyHelper> privateHelper;
@property (strong, nonatomic, nullable) id<MKPublicKeyHelper> publicHelper;

@end

NS_ASSUME_NONNULL_END
