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
//  MKMSymmetricKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMSymmetricKey.h"

@implementation MKMSymmetricKey

static NSString *promise = @"Moky loves May Lee forever!";

+ (BOOL)symmetricKey:(id<MKMSymmetricKey>)key1 equals:(id<MKMSymmetricKey>)key2 {
    // try to verify by en/decrypt
    NSData *data = [promise dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ciphertext = [key1 encrypt:data];
    NSData *plaintext = [key2 decrypt:ciphertext];
    return [plaintext isEqualToData:data];
}

- (NSData *)encrypt:(NSData *)plaintext {
    NSAssert(false, @"implement me!");
    return nil;
}

- (nullable NSData *)decrypt:(NSData *)ciphertext {
    NSAssert(false, @"implement me!");
    return nil;
}

@end

@implementation MKMSymmetricKey (Creation)

static NSMutableDictionary<NSString *, id<MKMSymmetricKeyFactory>> *s_factories = nil;

static NSMutableDictionary<NSString *, id<MKMSymmetricKeyFactory>> *factories(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!s_factories) {
            s_factories = [[NSMutableDictionary alloc] init];
        }
    });
    return s_factories;
}

+ (nullable id<MKMSymmetricKeyFactory>)factoryForAlgorithm:(NSString *)algorithm {
    return [factories() objectForKey:algorithm];
}

+ (void)setFactory:(id<MKMSymmetricKeyFactory>)factory forAlgorithm:(NSString *)algorithm {
    [factories() setObject:factory forKey:algorithm];
}

+ (__kindof id<MKMSymmetricKey>)generate:(NSString *)algorithm {
    id<MKMSymmetricKeyFactory> factory = [self factoryForAlgorithm:algorithm];
    NSAssert(factory, @"key algorithm not found: %@", algorithm);
    return [factory generateSymmetricKey];
}

+ (nullable __kindof id<MKMSymmetricKey>)parse:(NSDictionary *)key {
    if (key.count == 0) {
        return nil;
    } else if ([key conformsToProtocol:@protocol(MKMSymmetricKey)]) {
        return (id<MKMSymmetricKey>)key;
    } else if ([key conformsToProtocol:@protocol(MKMDictionary)]) {
        key = [(id<MKMDictionary>)key dictionary];
    }
    NSString *algorithm = [MKMCryptographyKey algorithm:key];
    NSAssert(algorithm, @"failed to get algorithm name for key: %@", key);
    id<MKMSymmetricKeyFactory> factory = [self factoryForAlgorithm:algorithm];
    if (!factory) {
        factory = [self factoryForAlgorithm:@"*"]; // unknown
        NSAssert(factory, @"cannot parse key: %@", key);
    }
    return [factory parseSymmetricKey:key];
}

@end
