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

#import <MingKeMing/MKMDictionary.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  enum MKMMetaVersion
 *
 *  abstract Defined for algorithm that generating address.
 *
 *  discussion Generate and check ID/Address
 *
 *      MKMMetaVersion_MKM give a seed string first, and sign this seed to get
 *      fingerprint; after that, use the fingerprint to generate address.
 *      This will get a firmly relationship between (username, address and key).
 *
 *      MKMMetaVersion_BTC use the key data to generate address directly.
 *      This can build a BTC address for the entity ID (no username).
 *
 *      MKMMetaVersion_ExBTC use the key data to generate address directly, and
 *      sign the seed to get fingerprint (just for binding username and key).
 *      This can build a BTC address, and bind a username to the entity ID.
 *
 *  Bits:
 *      0000 0001 - this meta contains seed as ID.name
 *      0000 0010 - this meta generate BTC address
 *      0000 0100 - this meta generate ETH address
 *      ...
 */
typedef NS_ENUM(UInt8, MKMMetaVersion) {
    
    MKMMetaVersion_MKM     = 0x01,  // 0000 0001
    
    MKMMetaVersion_BTC     = 0x02,  // 0000 0010
    MKMMetaVersion_ExBTC   = 0x03,  // 0000 0011
    
    MKMMetaVersion_ETH     = 0x04,  // 0000 0100
    MKMMetaVersion_ExETH   = 0x05,  // 0000 0101
};
typedef UInt8 MKMMetaType;
#define MKMMetaDefaultVersion MKMMetaVersion_MKM

#define MKMMeta_HasSeed(ver)    ((ver) & MKMMetaVersion_MKM)

@protocol MKMVerifyKey;
@protocol MKMSignKey;

@protocol MKMID;
@protocol MKMAddress;

/*
 *  User/Group Meta data
 *
 *      data format: {
 *          version    : 1,      // algorithm version
 *          key        : {...},  // PK = secp256k1(SK);
 *          seed       : "moKy", // user/group name
 *          fingerprint: "..."   // CT = sign(seed, SK);
 *      }
 *
 *      algorithm:
 *          fingerprint = sign(seed, SK);
 */
@protocol MKMMeta <MKMDictionary>

/**
 *  Meta algorithm version
 *
 *      0x01 - username@address
 *      0x02 - btc_address
 *      0x03 - username@btc_address
 *      0x04 - eth_address
 *      0x05 - username@eth_address
 *      ....
 */
@property (readonly, nonatomic) UInt8 type;

/**
 *  Public key
 *
 *      RSA / ECC
 */
@property (readonly, strong, nonatomic) __kindof id<MKMVerifyKey> key;

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

/**
 *  Generate address
 *
 * @param type - ID.type
 * @return Address
 */
- (nullable id<MKMAddress>)generateAddress:(UInt8)type;

@end

@protocol MKMMetaFactory <NSObject>

/**
 *  Generate meta
 *
 * @param SK - private key
 * @param name - ID.name
 * @return Meta
 */
- (id<MKMMeta>)generateMeta:(id<MKMSignKey>)SK seed:(nullable NSString *)name;

/**
 *  Create meta
 *
 * @param PK - public key
 * @param name - ID.name
 * @param CT - sKey.sign(seed)
 * @return Meta
 */
- (id<MKMMeta>)createMeta:(id<MKMVerifyKey>)PK seed:(nullable NSString *)name fingerprint:(nullable NSData *)CT;

/**
 *  Parse map object to meta
 *
 * @param meta - meta info
 * @return Meta
 */
- (nullable id<MKMMeta>)parseMeta:(NSDictionary *)meta;

@end

#ifdef __cplusplus
extern "C" {
#endif

id<MKMMetaFactory> MKMMetaGetFactory(UInt8 version);
void MKMMetaSetFactory(UInt8 version, id<MKMMetaFactory> factory);

id<MKMMeta> MKMMetaGenerate(UInt8 version, id<MKMSignKey> SK, NSString * _Nullable seed);
id<MKMMeta> MKMMetaCreate(UInt8 version, id<MKMVerifyKey> PK, NSString * _Nullable seed, NSData * _Nullable fingerprint);
id<MKMMeta> MKMMetaParse(id meta);

UInt8 MKMMetaGetType(NSDictionary<NSString *, id> *meta);
__kindof id<MKMVerifyKey> MKMMetaGetKey(NSDictionary<NSString *, id> *meta);
NSString * _Nullable MKMMetaGetSeed(NSDictionary<NSString *, id> *meta);
NSData * _Nullable MKMMetaGetFingerprint(NSDictionary<NSString *, id> *meta);

BOOL MKMMetaCheck(id<MKMMeta> meta);

// Check whether meta match the ID (must call this when received a new meta from network)
BOOL MKMMetaMatchID(id<MKMID> ID, id<MKMMeta> meta);

// Check whether meta match the public key
BOOL MKMMetaMatchKey(id<MKMVerifyKey> PK, id<MKMMeta> meta);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

#define MKMMetaFromDictionary(dict)    MKMMetaParse(dict)

#define MKMMetaRegister(type, factory) MKMMetaSetFactory(type, factory)

#pragma mark - Base Class

@interface MKMMeta : MKMDictionary <MKMMeta>

/**
 *  Create meta with dictionary
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithType:(UInt8)version
                         key:(id<MKMVerifyKey>)PK
                        seed:(nullable NSString *)name
                 fingerprint:(nullable NSData *)CT
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
