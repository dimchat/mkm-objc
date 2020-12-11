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
        [self setObject:publicKey forKey:@"key"];
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

- (id)copyWithZone:(NSZone *)zone {
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

- (MKMNetworkType)type {
    if (_type == 0) {
        NSNumber *version = [self objectForKey:@"version"];
        if (version == nil) {
            version = [self objectForKey:@"type"];
        }
        _type = [version unsignedCharValue];
    }
    return _type;
}

- (id<MKMVerifyKey>)key {
    if (!_key) {
        NSDictionary *key = [self objectForKey:@"key"];
        _key = MKMPublicKeyFromDictionary(key);
    }
    return _key;
}

- (nullable NSString *)seed {
    if (!_seed) {
        if (MKMMeta_HasSeed(self.type)) {
            _seed = [self objectForKey:@"seed"];
            NSAssert([_seed length] > 0, @"meta.seed should not be empty: %@", self);
        }
    }
    return _seed;
}

- (nullable NSData *)fingerprint {
    if (!_fingerprint) {
        if (MKMMeta_HasSeed(self.type)) {
            NSString *base64 = [self objectForKey:@"fingerprint"];
            NSAssert([base64 length] > 0, @"meta.fingerprint should not be empty: %@", self);
            _fingerprint = MKMBase64Decode(base64);
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

- (BOOL)matchID:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return NO;
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

static id<MKMMetaFactory> s_factory = nil;

+ (void)setFactory:(id<MKMMetaFactory>)factory {
    s_factory = factory;
}

+ (__kindof id<MKMMeta>)createWithType:(MKMMetaType)version
                                   key:(id<MKMPublicKey>)PK
                                  seed:(nullable NSString *)name
                           fingerprint:(nullable NSData *)CT {
    return [s_factory createMetaWithType:version key:PK seed:name fingerprint:CT];
}

+ (__kindof id<MKMMeta>)generateWithType:(MKMMetaType)version
                              privateKey:(id<MKMPrivateKey>)SK
                                    seed:(nullable NSString *)name {
    return [s_factory generateMetaWithType:version privateKey:SK seed:name];
}

+ (nullable __kindof id<MKMMeta>)parse:(NSDictionary *)meta {
    if (meta.count == 0) {
        return nil;
    } else if ([meta conformsToProtocol:@protocol(MKMMeta)]) {
        return (id<MKMMeta>)meta;
    } else if ([meta conformsToProtocol:@protocol(MKMDictionary)]) {
        meta = [(id<MKMDictionary>)meta dictionary];
    }
    return [s_factory parseMeta:meta];
}

@end
