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
//  MKMPrivateKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "MKMPublicKey.h"

#import "MKMPrivateKey.h"

@implementation MKMPrivateKey

- (BOOL)isEqual:(id)object {
    // 1. if the two keys have same contents, return YES
    if ([super isEqual:object]) {
        return YES;
    }
    if (![object isKindOfClass:[MKMPrivateKey class]]) {
        return NO;
    }
    // 2. try to verify by public key
    return [self.publicKey isMatch:(MKMPrivateKey *)object];
}

- (nullable __kindof MKMPublicKey *)publicKey {
    // implements in subclass
    return nil;
}

- (NSData *)sign:(NSData *)data {
    NSAssert(false, @"override me!");
    return nil;
}

@end

static NSMutableDictionary<NSString *, Class> *key_classes(void) {
    static NSMutableDictionary<NSString *, Class> *classes = nil;
    SingletonDispatchOnce(^{
        classes = [[NSMutableDictionary alloc] init];
        // RSA
        // ECC
        // ...
    });
    return classes;
}

@implementation MKMPrivateKey (Runtime)

+ (void)registerClass:(Class)keyClass forAlgorithm:(NSString *)name {
    if (keyClass) {
        NSAssert([keyClass isSubclassOfClass:self], @"error: %@", keyClass);
        [key_classes() setObject:keyClass forKey:name];
    } else {
        [key_classes() removeObjectForKey:name];
    }
}

+ (nullable instancetype)getInstance:(id)key {
    if (!key) {
        return nil;
    }
    if ([key isKindOfClass:[MKMPrivateKey class]]) {
        // return PrivateKey object directly
        return key;
    }
    NSAssert([key isKindOfClass:[NSDictionary class]], @"private key error: %@", key);
    if ([self isEqual:[MKMPrivateKey class]]) {
        // create instance by subclass with key algorithm
        NSString *algorithm = [key objectForKey:@"algorithm"];
        Class clazz = [key_classes() objectForKey:algorithm];
        if (clazz) {
            return [clazz getInstance:key];
        }
        NSAssert(false, @"private key not support: %@", key);
        return nil;
    }
    // subclass
    return [[self alloc] initWithDictionary:key];
}

@end

@implementation MKMPrivateKey (PersistentStore)

+ (nullable instancetype)loadKeyWithIdentifier:(NSString *)identifier {
    if (![self isEqual:[MKMPrivateKey class]]) {
        // subclass
        NSAssert(false, @"override me!");
        return nil;
    }
    MKMPrivateKey *key = nil;
    NSArray<Class> *classes = [key_classes() allValues];
    for (Class clazz in classes) {
        key = [clazz loadKeyWithIdentifier:identifier];
        if (key) {
            // found
            break;
        }
    }
    return key;
}

@end
