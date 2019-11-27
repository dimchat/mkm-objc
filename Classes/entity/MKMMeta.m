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

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"

#import "MKMMeta.h"

@interface MKMMeta () {
    
    MKMMetaType _version;
    id<MKMVerifyKey> _key;
    NSString *_seed;
    NSData *_fingerprint;
}

@end

@implementation MKMMeta

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    NSDictionary *dict = nil;
    return [self initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // version
        NSNumber *ver = [dict objectForKey:@"version"];
        MKMMetaType version = [ver unsignedCharValue];
        // public key
        NSDictionary *key = [dict objectForKey:@"key"];
        MKMPublicKey *PK = MKMPublicKeyFromDictionary(key);
        
        if (version & MKMMetaVersion_MKM) { // MKM, ExBTC, ExETH, ...
            // seed
            NSString *seed = [dict objectForKey:@"seed"];
            // fingerprint
            NSString *fingerprint = [dict objectForKey:@"fingerprint"];
            NSData *CT = [fingerprint base64Decode];
            
            if (![PK verify:[seed data] withSignature:CT]) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException
                                               reason:@"Meta key not match"
                                             userInfo:dict];
            }
            _seed = seed;
            _fingerprint = CT;
        } else { // BTC, ETH, ...
            _seed = nil;
            _fingerprint = nil;
        }
        _version = version;
        _key = PK;
    }
    return self;
}

+ (instancetype)generateWithVersion:(MKMMetaType)version
                         privateKey:(id<MKMSignKey>)SK
                               seed:(nullable NSString *)name {
    NSDictionary *dict;
    if (version & MKMMetaVersion_MKM) { // MKM, ExBTC, ExETH, ...
        NSData *CT = [SK sign:[name data]];
        NSString *fingerprint = [CT base64Encode];
        dict = @{@"version"    :@(version),
                 @"key"        :[(id<MKMPrivateKey>)SK publicKey],
                 @"seed"       :name,
                 @"fingerprint":fingerprint,
                 };
    } else { // BTC, ETH, ...
        dict = @{@"version"    :@(version),
                 @"key"        :[(id<MKMPrivateKey>)SK publicKey],
                 };
    }
    return [self getInstance:dict];
}

- (BOOL)matchPublicKey:(id<MKMVerifyKey>)PK {
    if ([PK isEqual:_key]) {
        return YES;
    }
    if (_version & MKMMetaVersion_MKM) { // MKM, ExBTC, ExETH, ...
        // check whether keys equal by verifying signature
        return [PK verify:[_seed data] withSignature:_fingerprint];
    } else { // BTC, ETH, ...
        // ID with BTC address has no username
        // so we can just compare the key.data to check matching
        return NO;
    }
}

#pragma mark - ID & address

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
@interface MKMMetaDefault : MKMMeta

@end

@implementation MKMMetaDefault

- (MKMAddress *)generateAddress:(MKMNetworkType)type {
    NSAssert(self.version == MKMMetaVersion_MKM, @"meta version error");
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
