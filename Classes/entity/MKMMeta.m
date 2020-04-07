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
//  MKMMeta.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMBaseCoder.h"

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"

#import "MKMMeta.h"

@interface MKMMeta () {
    
    MKMMetaType _version;
    id<MKMVerifyKey> _key;
    NSString *_seed;
    NSData *_fingerprint;
    
    NSInteger _status; // valid status
}

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
        _version = 0;
        _key = nil;
        _seed = nil;
        _fingerprint = nil;
        
        _status = 0; // 1 for valid, -1 for invalid
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([super isEqual:object]) {
        return YES;
    }
    MKMMeta *meta;
    if ([object isKindOfClass:[MKMMeta class]]) {
        meta = (MKMMeta *)object;
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        meta = MKMMetaFromDictionary(object);
    } else {
        NSAssert(!object, @"meta error: %@", object);
        return NO;
    }
    MKMID *ID = [meta generateID:MKMNetwork_Main];
    return [self matchID:ID];
}

- (MKMNetworkType)version {
    if (_version == 0) {
        NSNumber *ver = [self objectForKey:@"version"];
        _version = [ver unsignedCharValue];
    }
    return _version;
}

- (BOOL)containsSeed {
    return MKMMetaVersion_HasSeed([self version]);
}

- (__kindof id<MKMVerifyKey>)key {
    if (!_key) {
        NSDictionary *key = [self objectForKey:@"key"];
        _key = MKMPublicKeyFromDictionary(key);
    }
    return _key;
}

- (nullable NSString *)seed {
    if (!_seed) {
        if ([self containsSeed]) {
            _seed = [self objectForKey:@"seed"];
            NSAssert([_seed length] > 0, @"meta.seed should not be empty: %@", self);
        }
    }
    return _seed;
}

- (nullable NSData *)fingerprint {
    if (!_fingerprint) {
        if ([self containsSeed]) {
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
            _status = -1;
        } else if ([self containsSeed]) {
            NSString *seed = [self seed];
            NSData *fingerprint = [self fingerprint];
            NSAssert([seed length] > 0, @"seed error");
            NSAssert([fingerprint length] > 0, @"fingerprint error");
            if ([key verify:[seed data] withSignature:fingerprint]) {
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

+ (instancetype)generateWithVersion:(MKMMetaType)version
                         privateKey:(id<MKMPrivateKey>)SK
                               seed:(nullable NSString *)name {
    NSDictionary *dict;
    if (MKMMetaVersion_HasSeed(version)) { // MKM, ExBTC, ExETH, ...
        NSData *CT = [SK sign:[name data]];
        NSString *fingerprint = MKMBase64Encode(CT);
        dict = @{@"version"    :@(version),
                 @"key"        :[SK publicKey],
                 @"seed"       :name,
                 @"fingerprint":fingerprint,
                 };
    } else { // BTC, ETH, ...
        dict = @{@"version"    :@(version),
                 @"key"        :[SK publicKey],
                 };
    }
    return [self getInstance:dict];
}

- (BOOL)matchPublicKey:(id<MKMVerifyKey>)PK {
    if (![self isValid]) {
        return NO;
    }
    if ([PK isEqual:self.key]) {
        return YES;
    }
    if ([self containsSeed]) { // MKM, ExBTC, ExETH, ...
        // check whether keys equal by verifying signature
        return [PK verify:[self.seed data] withSignature:self.fingerprint];
    } else { // BTC, ETH, ...
        // ID with BTC address has no username
        // so we can just compare the key.data to check matching
        return NO;
    }
}

#pragma mark ID & address

- (BOOL)matchID:(MKMID *)ID {
    return [ID isEqual:[self generateID:ID.address.network]];
}

- (BOOL)matchAddress:(MKMAddress *)address {
    return [address isEqual:[self generateAddress:address.network]];
}

- (MKMID *)generateID:(MKMNetworkType)type {
    MKMAddress *address = [self generateAddress:type];
    return [[MKMID alloc] initWithName:_seed address:address];
}

- (MKMAddress *)generateAddress:(MKMNetworkType)type {
    NSAssert(false, @"override me!");
    return nil;
}

@end

#pragma mark - Default Meta

/**
 *  Default Meta to build ID with 'name@address'
 *
 *  version:
 *      0x01 - MKM
 */
@interface MKMMetaDefault : MKMMeta {
    
    NSMutableDictionary<NSNumber *, MKMID *> *_idMap;
}

@end

@implementation MKMMetaDefault

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        _idMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (MKMID *)generateID:(MKMNetworkType)type {
    NSNumber *key = @(type);
    // check cache
    MKMID *ID = [_idMap objectForKey:key];
    if (!ID) {
        // generate and cache it
        ID = [super generateID:type];
        NSAssert([ID isValid], @"failed to generate ID: %@", self);
        [_idMap setObject:ID forKey:key];
    }
    return ID;
}

- (MKMAddress *)generateAddress:(MKMNetworkType)type {
    NSAssert([self version] == MKMMetaVersion_MKM, @"meta version error");
    if (![self isValid]) {
        NSAssert(false, @"meta invalid: %@", _storeDictionary);
        return nil;
    }
    // check cache
    MKMID *ID = [_idMap objectForKey:@(type)];
    if (ID) {
        return ID.address;
    }
    // generate
    return [MKMAddressDefault generateWithData:self.fingerprint network:type];
}

@end

#pragma mark - Runtime

static NSMutableDictionary<NSNumber *, Class> *meta_classes(void) {
    static NSMutableDictionary<NSNumber *, Class> *classes = nil;
    SingletonDispatchOnce(^{
        classes = [[NSMutableDictionary alloc] init];
        // MKM
        [classes setObject:[MKMMetaDefault class] forKey:@(MKMMetaVersion_MKM)];
        // BTC, ExBTC
        // ETH, EXETH
        // ...
    });
    return classes;
}

@implementation MKMMeta (Runtime)

+ (void)registerClass:(nullable Class)metaClass forVersion:(MKMMetaType)version {
    if (metaClass) {
        NSAssert([metaClass isSubclassOfClass:self], @"error: %@", metaClass);
        [meta_classes() setObject:metaClass forKey:@(version)];
    } else {
        [meta_classes() removeObjectForKey:@(version)];
    }
}

+ (nullable instancetype)getInstance:(id)meta {
    if (!meta) {
        return nil;
    }
    if ([meta isKindOfClass:[MKMMeta class]]) {
        // return Meta object directly
        return meta;
    }
    NSAssert([meta isKindOfClass:[NSDictionary class]], @"meta error: %@", meta);
    if ([self isEqual:[MKMMeta class]]) {
        // create instance by subclass with meta version
        NSNumber *version = [meta objectForKey:@"version"];
        Class clazz = [meta_classes() objectForKey:version];
        if (clazz) {
            return [clazz getInstance:meta];
        }
        NSAssert(false, @"meta not support: %@", meta);
        return nil;
    }
    // subclass
    return [[self alloc] initWithDictionary:meta];
}

@end
