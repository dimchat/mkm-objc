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
//  MKMMeta.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMWrapper.h"

#import "MKMDataCoder.h"
#import "MKMDataParser.h"

#import "MKMPublicKey.h"

#import "MKMID.h"

#import "MKMMeta.h"

static NSMutableDictionary<NSNumber *, id<MKMMetaFactory>> *s_factories = nil;

id<MKMMetaFactory> MKMMetaGetFactory(MKMMetaType version) {
    return [s_factories objectForKey:@(version)];
}

void MKMMetaSetFactory(MKMMetaType version, id<MKMMetaFactory> factory) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //if (!s_factories) {
            s_factories = [[NSMutableDictionary alloc] init];
        //}
    });
    [s_factories setObject:factory forKey:@(version)];
}

id<MKMMeta> MKMMetaGenerate(MKMMetaType version, id<MKMSignKey> SK, NSString * _Nullable seed) {
    id<MKMMetaFactory> factory = MKMMetaGetFactory(version);
    return [factory generateMeta:SK seed:seed];
}

id<MKMMeta> MKMMetaCreate(MKMMetaType version, id<MKMVerifyKey> PK, NSString * _Nullable seed, NSData * _Nullable fingerprint) {
    id<MKMMetaFactory> factory = MKMMetaGetFactory(version);
    return [factory createMeta:PK seed:seed fingerprint:fingerprint];
}

id<MKMMeta> MKMMetaParse(id meta) {
    if (!meta) {
        return nil;
    } else if ([meta conformsToProtocol:@protocol(MKMMeta)]) {
        return (id<MKMMeta>)meta;
    }
    meta = MKMGetMap(meta);
    MKMMetaType version = MKMMetaGetType(meta);
    id<MKMMetaFactory> factory = MKMMetaGetFactory(version);
    if (!factory) {
        factory = MKMMetaGetFactory(0);  // unknown
    }
    return [factory parseMeta:meta];
}

#pragma mark Getters

MKMMetaType MKMMetaGetType(NSDictionary<NSString *, id> *meta) {
    NSNumber *version = [meta objectForKey:@"type"];
    if (!version) {
        // compatible with v1.0
        version = [meta objectForKey:@"version"];
    }
    return [version unsignedCharValue];
}

id<MKMVerifyKey> MKMMetaGetKey(NSDictionary<NSString *, id> *meta) {
    id key = [meta objectForKey:@"key"];
    return MKMPublicKeyFromDictionary(key);
}

NSString *MKMMetaGetSeed(NSDictionary<NSString *, id> *meta) {
    return [meta objectForKey:@"seed"];
}

NSData *MKMMetaGetFingerprint(NSDictionary<NSString *, id> *meta) {
    NSString *base64 = [meta objectForKey:@"fingerprint"];
    if (base64.length == 0) {
        return nil;
    }
    return MKMBase64Decode(base64);
}

#pragma mark Checking

BOOL MKMMetaCheck(id<MKMMeta> meta) {
    id<MKMVerifyKey> key = meta.key;
    // meta.key should not be empty
    if (key) {
        if (MKMMeta_HasSeed(meta.type)) {
            // check seed with signature
            NSString *seed = meta.seed;
            NSData *fingerprint = meta.fingerprint;
            // seed and fingerprint should not be empty
            if (seed.length > 0 && fingerprint.length > 0) {
                // verify fingerprint
                return [key verify:MKMUTF8Encode(seed) withSignature:fingerprint];
            }
        } else {
            // this meta has no seed, so no signature too
            return YES;
        }
    }
    return NO;
}

BOOL MKMMetaMatchID(id<MKMID> ID, id<MKMMeta> meta) {
    // check ID.name
    NSString *name = ID.name;
    if (name) {
        if (![name isEqualToString:meta.seed]) {
            return NO;
        }
    } else if (meta.seed) {
        return NO;
    }
    // check ID.address
    id<MKMAddress> address = MKMAddressGenerate(ID.type, meta);
    return [address isEqual:ID.address];
}

BOOL MKMMetaMatchKey(id<MKMVerifyKey> PK, id<MKMMeta> meta) {
    if ([meta.key isEqual:PK]) {
        // NOTICE: ID with BTC/ETH address has no username, so
        //         just compare the key.data to check matching
        return YES;
    }
    // check with seed & fingerprint
    if (MKMMeta_HasSeed(meta.type)) {
        // check whether keys equal by verifying signature
        return [PK verify:MKMUTF8Encode(meta.seed) withSignature:meta.fingerprint];
    }
    return NO;
}

#pragma mark - Base Class

@interface MKMMeta ()

@property (nonatomic) MKMMetaType type;
@property (strong, nonatomic) id<MKMVerifyKey> key;
@property (strong, nonatomic, nullable) NSString *seed;
@property (strong, nonatomic, nullable) NSData *fingerprint;

@end

@implementation MKMMeta

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    NSDictionary *dict = nil;
    return [self initWithDictionary:dict];
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _type = 0;
        _key = nil;
        _seed = nil;
        _fingerprint = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(MKMMetaType)version
                         key:(id<MKMVerifyKey>)publicKey
                        seed:(nullable NSString *)seed
                 fingerprint:(nullable NSData *)fingerprint {
    NSDictionary *dict;
    if (seed && fingerprint) {
        dict = @{
            @"type": @(version),
            @"key": [publicKey dictionary],
            @"seed": seed,
            @"fingerprint": MKMBase64Encode(fingerprint),
        };
    } else {
        dict = @{
            @"type": @(version),
            @"key": [publicKey dictionary],
        };
    }
    if (self = [super initWithDictionary:dict]) {
        _type = version;
        _key = publicKey;
        _seed = seed;
        _fingerprint = fingerprint;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    MKMMeta *meta = [super copyWithZone:zone];
    if (meta) {
        meta.type = _type;
        meta.key = _key;
        meta.seed = _seed;
        meta.fingerprint = _fingerprint;
    }
    return meta;
}

- (MKMMetaType)type {
    if (_type == 0) {
        _type = MKMMetaGetType(self.dictionary);
    }
    return _type;
}

- (id<MKMVerifyKey>)key {
    if (!_key) {
        _key = MKMMetaGetKey(self.dictionary);
    }
    return _key;
}

- (nullable NSString *)seed {
    if (!_seed) {
        if (MKMMeta_HasSeed(self.type)) {
            _seed = MKMMetaGetSeed(self.dictionary);
            NSAssert([_seed length] > 0, @"meta.seed should not be empty: %@", self);
        }
    }
    return _seed;
}

- (nullable NSData *)fingerprint {
    if (!_fingerprint) {
        if (MKMMeta_HasSeed(self.type)) {
            _fingerprint = MKMMetaGetFingerprint(self.dictionary);
            NSAssert([_fingerprint length] > 0, @"meta.fingerprint should not be empty: %@", self);
        }
    }
    return _fingerprint;
}

- (nullable id<MKMAddress>)generateAddress:(MKMEntityType)network {
    NSAssert(false, @"implement me!");
    return nil;
}

@end
