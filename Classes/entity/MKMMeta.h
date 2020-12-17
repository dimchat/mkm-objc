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

#import "MKMDictionary.h"

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

@class MKMID;

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
@property (readonly, nonatomic) MKMMetaType type;

/**
 *  Public key
 *
 *      RSA / ECC
 */
@property (readonly, strong, nonatomic) id<MKMVerifyKey> key;

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
 *  Check meta valid
 *
 *      (must call this when received a new meta from network)
 */
@property (readonly, nonatomic, getter=isValid) BOOL valid;

/**
 *  Generate address
 *
 * @param type - ID.type
 * @return Address
 */
- (nullable id<MKMAddress>)generateAddress:(MKMNetworkType)type;

/**
 *  Generate ID with terminal
 *
 * @param type - ID.type
 * @param terminal - ID.terminal
 * @return ID
 */
- (nullable id<MKMID>)generateID:(MKMNetworkType)type
                        terminal:(nullable NSString *)terminal;

/**
 *  Check whether meta match with entity ID
 *  (must call this when received a new meta from network)
 *
 * @param ID - entity ID
 * @return true on matched
 */
- (BOOL)matchID:(id<MKMID>)ID;

/**
 *  Check whether meta match with public key
 *
 * @param PK - public key
 * @return true on matched
 */
- (BOOL)matchPublicKey:(id<MKMVerifyKey>)PK;

@end

@interface MKMMeta : MKMDictionary <MKMMeta>

+ (MKMMetaType)type:(NSDictionary *)meta;

+ (id<MKMVerifyKey>)key:(NSDictionary *)meta;

+ (nullable NSString *)seed:(NSDictionary *)meta;

+ (nullable NSData *)fingerprint:(NSDictionary *)meta;

/**
 *  Create meta with dictionary
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithType:(MKMMetaType)version
                         key:(id<MKMVerifyKey>)PK
                        seed:(NSString *)name
                 fingerprint:(NSData *)CT
NS_DESIGNATED_INITIALIZER;

@end

// create meta with data loaded from local storage
#define MKMMetaCreate(t, PK, name, CT)                                         \
            [MKMMeta createWithType:(t) key:(PK) seed:(name) fingerprint:(CT)] \
                                      /* EOF 'MKMMetaCreate(t, PK, name, CT)' */

// generate Meta
#define MKMMetaGenerate(ver, SK, name)                                         \
            [MKMMeta generateWithType:(ver) privateKey:(SK) seed:(name)]       \
                                      /* EOF 'MKMMetaGenerate(ver, SK, name)' */

// convert Dictionary to Meta
#define MKMMetaFromDictionary(meta)                                            \
            [MKMMeta parse:(meta)]                                             \
                                         /* EOF 'MKMMetaFromDictionary(meta)' */

#pragma mark - Creation

@protocol MKMPublicKey;
@protocol MKMPrivateKey;

@protocol MKMMetaFactory <NSObject>

/**
 *  Create meta
 *
 * @param PK - public key
 * @param name - ID.name
 * @param CT - sKey.sign(seed)
 * @return Meta
 */
- (id<MKMMeta>)createMetaWithPublicKey:(id<MKMPublicKey>)PK
                                  seed:(nullable NSString *)name
                           fingerprint:(nullable NSData *)CT;

/**
 *  Generate meta
 *
 * @param SK - private key
 * @param name - ID.name
 * @return Meta
 */
- (id<MKMMeta>)generateMetaWithPrivateKey:(id<MKMPrivateKey>)SK
                                     seed:(nullable NSString *)name;

/**
 *  Parse map object to meta
 *
 * @param meta - meta info
 * @return Meta
 */
- (nullable id<MKMMeta>)parseMeta:(NSDictionary *)meta;

@end

@interface MKMMeta (Creation)

+ (id<MKMMetaFactory>)factoryForType:(MKMMetaType)type;
+ (void)setFactory:(id<MKMMetaFactory>)factory forType:(MKMMetaType)type;

+ (id<MKMMeta>)createWithType:(MKMMetaType)version
                          key:(id<MKMPublicKey>)PK
                         seed:(nullable NSString *)name
                  fingerprint:(nullable NSData *)CT;

+ (id<MKMMeta>)generateWithType:(MKMMetaType)version
                     privateKey:(id<MKMPrivateKey>)SK
                           seed:(nullable NSString *)name;

+ (nullable id<MKMMeta>)parse:(NSDictionary *)meta;

@end

NS_ASSUME_NONNULL_END
