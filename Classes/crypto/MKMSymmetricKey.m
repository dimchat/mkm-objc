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

static NSMutableDictionary<NSString *, id<MKMSymmetricKeyFactory>> *s_factories = nil;

id<MKMSymmetricKeyFactory> MKMSymmetricKeyGetFactory(NSString *algorithm) {
    //NSAssert(s_factories, @"symmetric key factories not set yet");
    return [s_factories objectForKey:algorithm];
}

void MKMSymmetricKeySetFactory(NSString *algorithm, id<MKMSymmetricKeyFactory> factory) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //if (!s_factories) {
            s_factories = [[NSMutableDictionary alloc] init];
        //}
    });
    [s_factories setObject:factory forKey:algorithm];
}

id<MKMSymmetricKey> MKMSymmetricKeyGenerate(NSString *algorithm) {
    id<MKMSymmetricKeyFactory> factory = MKMSymmetricKeyGetFactory(algorithm);
    //NSAssert(factory, @"key algorithm not found: %@", algorithm);
    return [factory generateSymmetricKey];
}

id<MKMSymmetricKey> MKMSymmetricKeyParse(id key) {
    if (!key) {
        return nil;
    } else if ([key conformsToProtocol:@protocol(MKMSymmetricKey)]) {
        return (id<MKMSymmetricKey>)key;
    } else if ([key conformsToProtocol:@protocol(MKMDictionary)]) {
        key = [(id<MKMDictionary>)key dictionary];
    }
    //NSAssert([key isKindOfClass:[NSDictionary class]], @"key info error: %@", key);
    NSString *algorithm = MKMCryptographyKeyAlgorithm(key);
    //NSAssert(algorithm, @"failed to get algorithm name for key: %@", key);
    id<MKMSymmetricKeyFactory> factory = MKMSymmetricKeyGetFactory(algorithm);
    if (!factory) {
        factory = MKMSymmetricKeyGetFactory(@"*"); // unknown
        //NSAssert(factory, @"cannot parse key: %@", key);
    }
    return [factory parseSymmetricKey:key];
}

@implementation MKMSymmetricKey

- (BOOL)isEqual:(id)object {
    if ([super isEqual:object]) {
        return YES;
    }
    if ([object conformsToProtocol:@protocol(MKMSymmetricKey)]) {
        return [self isMatch:object];
    }
    return NO;
}

- (BOOL)isMatch:(id<MKMEncryptKey>)pKey {
    return MKMCryptographyKeysMatch(pKey, self);
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
