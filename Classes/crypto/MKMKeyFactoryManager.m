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
//  MKMKeyFactoryManager.m
//  MingKeMing
//
//  Created by Albert Moky on 2023/1/31.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "MKMWrapper.h"

#import "MKMKeyFactoryManager.h"

@implementation MKMKeyFactoryManager

static MKMKeyFactoryManager *s_manager = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [super allocWithZone:zone];
        s_manager.generalFactory = [[MKMGeneralKeyFactory alloc] init];
    });
    return s_manager;
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[self alloc] init];
    });
    return s_manager;
}

@end

#pragma mark -

// sample data for checking keys
static NSData *promise = nil;

static inline void prepare(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *words = @"Moky loves May Lee forever!";
        promise = [words dataUsingEncoding:NSUTF8StringEncoding];
    });
}

@interface MKMGeneralKeyFactory () {
    
    NSMutableDictionary<NSString *, id<MKMSymmetricKeyFactory>> *_symmetricFactories;
    NSMutableDictionary<NSString *, id<MKMPrivateKeyFactory>>   *_privateFactories;
    NSMutableDictionary<NSString *, id<MKMPublicKeyFactory>>    *_publicFactories;
}

@end

@implementation MKMGeneralKeyFactory

- (instancetype)init {
    if ([super init]) {
        _symmetricFactories = [[NSMutableDictionary alloc] init];
        _privateFactories   = [[NSMutableDictionary alloc] init];
        _publicFactories    = [[NSMutableDictionary alloc] init];
        prepare();
    }
    return self;
}

- (nullable NSString *)algorithm:(NSDictionary<NSString *,id> *)keyInfo {
    return [keyInfo objectForKey:@"algorithm"];
}

- (BOOL)isSignKey:(id<MKMSignKey>)sKey matchVerifyKey:(id<MKMVerifyKey>)pKey {
    //prepare();
    NSData *signature = [sKey sign:promise];
    return [pKey verify:promise withSignature:signature];
}

- (BOOL)isEncryptKey:(id<MKMEncryptKey>)pKey matchDecryptKey:(id<MKMDecryptKey>)sKey {
    //prepare();
    NSData *ciphertext = [pKey encrypt:promise];
    NSData *plaintext = [sKey decrypt:ciphertext];
    // check result
    return [plaintext isEqualToData:promise];
}

#pragma mark SymmetricKey

- (void)setSymmetricKeyFactory:(id<MKMSymmetricKeyFactory>)factory
                  forAlgorithm:(NSString *)algorithm {
    [_symmetricFactories setObject:factory forKey:algorithm];
}

- (nullable id<MKMSymmetricKeyFactory>)symmetricKeyFactoryForAlgorithm:(NSString *)algorithm {
    return [_symmetricFactories objectForKey:algorithm];
}

- (nullable id<MKMSymmetricKey>)generateSymmetricKeyWithAlgorithm:(NSString *)algorithm {
    id<MKMSymmetricKeyFactory> factory = [self symmetricKeyFactoryForAlgorithm:algorithm];
    NSAssert(factory, @"key algorithm not found: %@", algorithm);
    return [factory generateSymmetricKey];
}

- (nullable id<MKMSymmetricKey>)parseSymmetricKey:(id)key {
    if (!key) {
        return nil;
    } else if ([key conformsToProtocol:@protocol(MKMSymmetricKey)]) {
        return (id<MKMSymmetricKey>)key;
    }
    NSDictionary<NSString *, id> *info = MKMGetMap(key);
    NSAssert([info isKindOfClass:[NSDictionary class]], @"key error: %@", key);
    NSString *algorithm = [self algorithm:info];
    if (!algorithm) {
        algorithm = @"*";
    }
    id<MKMSymmetricKeyFactory> factory = [self symmetricKeyFactoryForAlgorithm:algorithm];
    if (!factory && ![algorithm isEqualToString:@"*"]) {
        factory = [self symmetricKeyFactoryForAlgorithm:@"*"]; // unknown
    }
    NSAssert(factory, @"cannot parse key: %@", key);
    return [factory parseSymmetricKey:info];
}

#pragma mark PrivateKey

- (void)setPrivateKeyFactory:(id<MKMPrivateKeyFactory>)factory forAlgorithm:(NSString *)algorithm {
    [_privateFactories setObject:factory forKey:algorithm];
}

- (nullable id<MKMPrivateKeyFactory>)privateKeyFactoryForAlgorithm:(NSString *)algorithm {
    return [_privateFactories objectForKey:algorithm];
}

- (nullable id<MKMPrivateKey>)generatePrivateKeyWithAlgorithm:(NSString *)algorithm {
    id<MKMPrivateKeyFactory> factory = [self privateKeyFactoryForAlgorithm:algorithm];
    NSAssert(factory, @"key algorithm not found: %@", algorithm);
    return [factory generatePrivateKey];
}

- (nullable id<MKMPrivateKey>)parsePrivateKey:(id)key {
    if (!key) {
        return nil;
    } else if ([key conformsToProtocol:@protocol(MKMPrivateKey)]) {
        return (id<MKMPrivateKey>)key;
    }
    NSDictionary<NSString *, id> *info = MKMGetMap(key);
    NSAssert([info isKindOfClass:[NSDictionary class]], @"key error: %@", key);
    NSString *algorithm = [self algorithm:info];
    if (!algorithm) {
        algorithm = @"*";
    }
    id<MKMPrivateKeyFactory> factory = [self privateKeyFactoryForAlgorithm:algorithm];
    if (!factory && ![algorithm isEqualToString:@"*"]) {
        factory = [self privateKeyFactoryForAlgorithm:@"*"]; // unknown
    }
    NSAssert(factory, @"cannot parse key: %@", key);
    return [factory parsePrivateKey:info];
}

#pragma mark PublicKey

- (void)setPublicKeyFactory:(id<MKMPublicKeyFactory>)factory forAlgorithm:(NSString *)algorithm {
    [_publicFactories setObject:factory forKey:algorithm];
}

- (nullable id<MKMPublicKeyFactory>)publicKeyFactoryForAlgorithm:(NSString *)algorithm {
    return [_publicFactories objectForKey:algorithm];
}

- (nullable id<MKMPublicKey>)parsePublicKey:(id)key {
    if (!key) {
        return nil;
    } else if ([key conformsToProtocol:@protocol(MKMPublicKey)]) {
        return (id<MKMPublicKey>)key;
    }
    NSDictionary<NSString *, id> *info = MKMGetMap(key);
    NSAssert([info isKindOfClass:[NSDictionary class]], @"key error: %@", key);
    NSString *algorithm = [self algorithm:info];
    if (!algorithm) {
        algorithm = @"*";
    }
    id<MKMPublicKeyFactory> factory = [self publicKeyFactoryForAlgorithm:algorithm];
    if (!factory && ![algorithm isEqualToString:@"*"]) {
        factory = [self publicKeyFactoryForAlgorithm:@"*"]; // unknown
    }
    NSAssert(factory, @"cannot parse key: %@", key);
    return [factory parsePublicKey:info];
}

@end
