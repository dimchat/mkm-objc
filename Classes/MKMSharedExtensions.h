// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2025 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2025 Albert Moky
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
//  MKMSharedExtensions.h
//  MingKeMing
//
//  Created by Albert Moky on 2025/10/1.
//  Copyright © 2025 DIM Group. All rights reserved.
//

#import <MingKeMing/MKAsymmetricKey.h>
#import <MingKeMing/MKCryptoHelpers.h>
#import <MingKeMing/MKFormatHelpers.h>
#import <MingKeMing/MKMAccountHelpers.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif

// sample data for checking keys
NSData *MKMakePromise(void); // 'Moky loves May Lee forever!'

// verify with signature
BOOL MKMatchAsymmetricKeys(id<MKSignKey> sKey, id<MKVerifyKey> pKey);

// check by encryption
BOOL MKMatchSymmetricKeys(id<MKEncryptKey> encKey, id<MKDecryptKey> decKey);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

@protocol MKGeneralCryptoHelper <NSObject/*,
                                          MKSymmetricKeyHelper,
                                          MKPrivateKeyHelper,
                                          MKPublicKeyHelper
                                          */>

//
//  Algorithm
//
- (nullable NSString *)getKeyAlgorithm:(NSDictionary<NSString *, id> *)key
                          defaultValue:(nullable NSString *)aValue;

@end

#pragma mark CryptographyKey FactoryManager

@interface MKSharedCryptoExtensions : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic, nullable) id<MKSymmetricKeyHelper> symmetricHelper;

@property (strong, nonatomic, nullable) id<MKPrivateKeyHelper> privateHelper;
@property (strong, nonatomic, nullable) id<MKPublicKeyHelper> publicHelper;

@property (strong, nonatomic, nullable) id<MKGeneralCryptoHelper> helper;

@end


#pragma mark -

@protocol MKGeneralFormatHelper <NSObject/*,
                                          MKTransportableDataHelper,
                                          MKPortableNetworkFileHelper
                                          */>

//
//  Algorithm
//
- (nullable NSString *)getFormatAlgorithm:(NSDictionary<NSString *, id> *)ted
                             defaultValue:(nullable NSString *)aValue;

@end

#pragma mark Format FactoryManager

@interface MKSharedFormatExtensions : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic, nullable) id<MKTransportableDataHelper> tedHelper;

@property (strong, nonatomic, nullable) id<MKPortableNetworkFileHelper> pnfHelper;

@property (strong, nonatomic, nullable) id<MKGeneralFormatHelper> helper;

@end

#pragma mark -

@protocol MKMGeneralAccountHelper <NSObject/*,
                                            MKMAddressHelper,
                                            MKMIdentifierHelper,
                                            MKMMetaHelper,
                                            MKMDocumentHelper
                                            */>

//
//  Algorithm Version
//
- (nullable NSString *)getMetaType:(NSDictionary<NSString *, id> *)meta
                      defaultValue:(nullable NSString *)aValue;

- (nullable NSString *)getDocumentType:(NSDictionary<NSString *, id> *)doc
                          defaultValue:(nullable NSString *)aValue;

@end

#pragma mark Account FactoryManager

@interface MKMSharedAccountExtensions : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic, nullable) id<MKMAddressHelper> addressHelper;
@property (strong, nonatomic, nullable) id<MKMIdentifierHelper> idHelper;
@property (strong, nonatomic, nullable) id<MKMMetaHelper> metaHelper;
@property (strong, nonatomic, nullable) id<MKMDocumentHelper> docHelper;

@property (strong, nonatomic, nullable) id<MKMGeneralAccountHelper> helper;

@end

NS_ASSUME_NONNULL_END
