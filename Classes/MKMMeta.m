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

#import "MKMDataCoder.h"
#import "MKMDataParser.h"

#import "MKMPublicKey.h"

#import "MKMID.h"

#import "MKMMeta.h"

@interface MKMMeta ()

@property (nonatomic) MKMMetaType type;
@property (strong, nonatomic) id<MKMVerifyKey> key;
@property (strong, nonatomic, nullable) NSString *seed;
@property (strong, nonatomic, nullable) NSData *fingerprint;

@property (nonatomic) NSInteger status;; // 1 for valid, -1 for invalid

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
        
        _status = 0;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(MKMMetaType)version
                         key:(id<MKMVerifyKey>)publicKey
                        seed:(NSString *)seed
                 fingerprint:(NSData *)fingerprint {
    if (self = [super init]) {
        
        // meta type
        [self setObject:@(version) forKey:@"version"];
        _type = version;
        
        // public key
        [self setObject:[publicKey dictionary] forKey:@"key"];
        _key = publicKey;
        
        if (seed.length > 0) {
            [self setObject:seed forKey:@"seed"];
        }
        _seed = seed;
        
        if (fingerprint.length > 0) {
            NSString *base64 = [MKMBase64 encode:fingerprint];
            [self setObject:base64 forKey:@"fingerprint"];
        }
        _fingerprint = fingerprint;
        
        _status = 0;
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
        meta.status = _status;
    }
    return meta;
}

+ (MKMMetaType)type:(NSDictionary *)meta {
    NSNumber *version = [meta objectForKey:@"type"];
    if (!version) {
        // compatible with v1.0
        version = [meta objectForKey:@"version"];
        NSAssert(version, @"meta type not found: %@", meta);
    }
    return [version unsignedCharValue];
}

- (MKMMetaType)type {
    if (_type == 0) {
        _type = [MKMMeta type:self.dictionary];
    }
    return _type;
}

+ (id<MKMVerifyKey>)key:(NSDictionary *)meta {
    NSDictionary *key = [meta objectForKey:@"key"];
    NSAssert([key isKindOfClass:[NSDictionary class]], @"meta key not found: %@", meta);
    return MKMPublicKeyFromDictionary(key);
}

- (id<MKMVerifyKey>)key {
    if (!_key) {
        _key = [MKMMeta key:self.dictionary];
    }
    return _key;
}

+ (nullable NSString *)seed:(NSDictionary *)meta {
    return [meta objectForKey:@"seed"];
}

- (nullable NSString *)seed {
    if (!_seed) {
        if (MKMMeta_HasSeed(self.type)) {
            _seed = [MKMMeta seed:self.dictionary];
            NSAssert([_seed length] > 0, @"meta.seed should not be empty: %@", self);
        }
    }
    return _seed;
}

+ (nullable NSData *)fingerprint:(NSDictionary *)meta {
    NSString *base64 = [meta objectForKey:@"fingerprint"];
    if (base64.length == 0) {
        return nil;
    }
    return MKMBase64Decode(base64);
}

- (nullable NSData *)fingerprint {
    if (!_fingerprint) {
        if (MKMMeta_HasSeed(self.type)) {
            _fingerprint = [MKMMeta fingerprint:self.dictionary];
            NSAssert(_fingerprint.length > 0, @"meta.fingerprint should not be empty: %@", self);
        }
    }
    return _fingerprint;
}

- (BOOL)isValid {
    if (_status == 0) {
        id<MKMVerifyKey> key = [self key];
        if (!key) {
            // meta.key should not be empty
            _status = -1;
        } else if (MKMMeta_HasSeed(self.type)) {
            NSString *seed = [self seed];
            NSData *fingerprint = [self fingerprint];
            if (seed.length == 0 || fingerprint.length == 0) {
                // seed and fingerprint should not be empty
                _status = -1;
            } else if ([key verify:MKMUTF8Encode(seed) withSignature:fingerprint]) {
                // fingerprint matched
                _status = 1;
            } else {
                // fingerprint not matched
                _status = -1;
            }
        } else {
            // this meta has no seed
            _status = 1;
        }
    }
    return _status == 1;
}

- (nullable __kindof id<MKMAddress>)generateAddress:(MKMNetworkType)type {
    NSAssert(false, @"implement me!");
    return nil;
}

- (nullable id<MKMID>)generateID:(MKMNetworkType)type
                        terminal:(nullable NSString *)terminal {
    id<MKMAddress> address = [self generateAddress:type];
    if (!address) {
        NSAssert(false, @"failed to generate address with type: %d", type);
        return nil;
    }
    return [[MKMID alloc] initWithName:self.seed address:address terminal:terminal];
}

- (BOOL)matchID:(id<MKMID>)ID {
    // check ID.name
    NSString *seed = self.seed;
    if (seed.length == 0) {
        if (ID.name.length > 0) {
            return NO;
        }
    } else if (![seed isEqualToString:ID.name]) {
        return NO;
    }
    // check ID.address
    id<MKMAddress> address = [self generateAddress:ID.type];
    return [ID.address isEqual:address];
}

- (BOOL)matchPublicKey:(id<MKMVerifyKey>)PK {
    if (![self isValid]) {
        return NO;
    }
    if ([PK isEqual:self.key]) {
        return YES;
    }
    if (MKMMeta_HasSeed(self.type)) { // MKM, ExBTC, ExETH, ...
        // check whether keys equal by verifying signature
        NSString *seed = [self seed];
        NSData *fingerprint = [self fingerprint];
        return [PK verify:MKMUTF8Encode(seed) withSignature:fingerprint];
    } else { // BTC, ETH, ...
        // ID with BTC address has no username
        // so we can just compare the key.data to check matching
        return NO;
    }
}

@end

#pragma mark - Creation

@implementation MKMMeta (Creation)

static NSMutableDictionary<NSNumber *, id<MKMMetaFactory>> *s_factories = nil;

+ (void)setFactory:(id<MKMMetaFactory>)factory forType:(MKMMetaType)type {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //if (!s_factories) {
            s_factories = [[NSMutableDictionary alloc] init];
        //}
    });
    [s_factories setObject:factory forKey:@(type)];
}

+ (id<MKMMetaFactory>)factoryForType:(MKMMetaType)type {
    NSAssert(s_factories, @"meta factories not set yet");
    return [s_factories objectForKey:@(type)];
}

+ (__kindof id<MKMMeta>)createWithType:(MKMMetaType)version
                                   key:(id<MKMPublicKey>)PK
                                  seed:(nullable NSString *)name
                           fingerprint:(nullable NSData *)CT {
    id<MKMMetaFactory> factory = [self factoryForType:version];
    NSAssert(factory, @"meta type not found: %d", version);
    return [factory createMetaWithPublicKey:PK seed:name fingerprint:CT];
}

+ (__kindof id<MKMMeta>)generateWithType:(MKMMetaType)version
                              privateKey:(id<MKMPrivateKey>)SK
                                    seed:(nullable NSString *)name {
    id<MKMMetaFactory> factory = [self factoryForType:version];
    NSAssert(factory, @"meta type not found: %d", version);
    return [factory generateMetaWithPrivateKey:SK seed:name];
}

+ (nullable __kindof id<MKMMeta>)parse:(NSDictionary *)meta {
    if (meta.count == 0) {
        return nil;
    } else if ([meta conformsToProtocol:@protocol(MKMMeta)]) {
        return (id<MKMMeta>)meta;
    } else if ([meta conformsToProtocol:@protocol(MKMDictionary)]) {
        meta = [(id<MKMDictionary>)meta dictionary];
    }
    MKMMetaType type = [self type:meta];
    id<MKMMetaFactory> factory = [self factoryForType:type];
    if (!factory) {
        factory = [self factoryForType:0];  // unknown
        NSAssert(factory, @"cannot parse meta: %@", meta);
    }
    return [factory parseMeta:meta];
}

@end
