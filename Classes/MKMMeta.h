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
//  MKMMeta.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <MingKeMing/MKDictionary.h>
#import <MingKeMing/MKMEntityType.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKTransportableData;

@protocol MKVerifyKey;
@protocol MKSignKey;

//@protocol MKMID;
@protocol MKMAddress;

/*
 *  User/Group Meta data
 *  ~~~~~~~~~~~~~~~~~~~~
 *  This class is used to generate entity ID
 *
 *      data format: {
 *          type        : 1,              // algorithm version
 *          key         : "{public key}", // PK = secp256k1(SK);
 *          seed        : "moKy",         // user/group name
 *          fingerprint : "..."           // CT = sign(seed, SK);
 *      }
 *
 *      algorithm:
 *          fingerprint = sign(seed, SK);
 */
@protocol MKMMeta <MKDictionary>

/**
 *  Meta algorithm version
 *
 *      1 = MKM : username@address (default)
 *      2 = BTC : btc_address
 *      4 = ETH : eth_address
 *      ....
 */
@property (readonly, strong, nonatomic) NSString *type;

/**
 *  Public key
 *
 *      RSA / ECC
 */
@property (readonly, strong, nonatomic) __kindof id<MKVerifyKey> publicKey;

/**
 *  Seed to generate fingerprint
 *
 *      Username / Group-X
 */
@property (readonly, strong, nonatomic, nullable) NSString *seed;

/**
 *  Fingerprint to verify ID and public key
 *
 *      Build: fingerprint = sign(seed, privateKey)
 *      Check: verify(seed, fingerprint, publicKey)
 */
@property (readonly, strong, nonatomic, nullable) NSData *fingerprint;

#pragma mark Validation

/**
 *  Check meta valid
 *  (must call this when received a new meta from network)
 *
 * @return NO on fingerprint not matched
 */
@property (readonly, nonatomic, getter=isValid) BOOL valid;

/**
 *  Generate address
 *
 * @param network - address type
 * @return Address
 */
- (__kindof id<MKMAddress>)generateAddress:(MKMEntityType)network;

@end

@protocol MKMMetaFactory <NSObject>

/**
 *  Generate meta
 *
 * @param SK   - private key
 * @param name - ID.name
 * @return Meta
 */
- (__kindof id<MKMMeta>)generateMetaWithKey:(id<MKSignKey>)SK
                                       seed:(nullable NSString *)name;

/**
 *  Create meta
 *
 * @param PK   - public key
 * @param name - ID.name
 * @param sig  - sKey.sign(seed)
 * @return Meta
 */
- (__kindof id<MKMMeta>)createMetaWithKey:(id<MKVerifyKey>)PK
                                     seed:(nullable NSString *)name
                              fingerprint:(nullable id<MKTransportableData>)sig;

/**
 *  Parse map object to meta
 *
 * @param meta - meta info
 * @return Meta
 */
- (nullable __kindof id<MKMMeta>)parseMeta:(NSDictionary *)meta;

@end

#ifdef __cplusplus
extern "C" {
#endif

_Nullable id<MKMMetaFactory> MKMMetaGetFactory(NSString *type);
void MKMMetaSetFactory(NSString *type, id<MKMMetaFactory> factory);

__kindof id<MKMMeta> MKMMetaGenerate(NSString *type, id<MKSignKey> SK,
                                     NSString * _Nullable seed);

__kindof id<MKMMeta> MKMMetaCreate(NSString *type, id<MKVerifyKey> PK,
                                   NSString * _Nullable seed,
                                   _Nullable id<MKTransportableData> fingerprint);

_Nullable __kindof id<MKMMeta> MKMMetaParse(_Nullable id meta);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
