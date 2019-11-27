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
//  MKMSymmetricKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "MKMAESKey.h"

#import "MKMSymmetricKey.h"

@implementation MKMSymmetricKey

- (BOOL)isEqual:(id)object {
    // 1. if the two keys have same contents, return YES
    if ([super isEqual:object]) {
        return YES;
    }
    if (![object isKindOfClass:[MKMSymmetricKey class]]) {
        return NO;
    }
    // 2. try to verify by en/decrypt
    MKMSymmetricKey *key = (MKMSymmetricKey *)object;
    static NSString *promise = @"Moky loves May Lee forever!";
    NSData *data = [promise dataUsingEncoding:NSUTF8StringEncoding];
    NSData *ciphertext = [key encrypt:data];
    NSData *plaintext = [self decrypt:ciphertext];
    return [plaintext isEqualToData:ciphertext];
}

- (NSData *)encrypt:(NSData *)plaintext {
    NSAssert(false, @"override me!");
    return nil;
}

- (nullable NSData *)decrypt:(NSData *)ciphertext {
    NSAssert(false, @"override me!");
    return nil;
}

@end

static NSMutableDictionary<NSString *, Class> *key_classes(void) {
    static NSMutableDictionary<NSString *, Class> *classes = nil;
    SingletonDispatchOnce(^{
        classes = [[NSMutableDictionary alloc] init];
        // AES
        [classes setObject:[MKMAESKey class] forKey:SCAlgorithmAES];
        [classes setObject:[MKMAESKey class] forKey:@"AES/CBC/PKCS7Padding"];
        // DES
        // ...
    });
    return classes;
}

@implementation MKMSymmetricKey (Runtime)

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
    if ([key isKindOfClass:[MKMSymmetricKey class]]) {
        // return SymmetricKey object directly
        return key;
    }
    NSAssert([key isKindOfClass:[NSDictionary class]], @"symmetric key error: %@", key);
    if ([self isEqual:[MKMSymmetricKey class]]) {
        // create instance by subclass with key algorithm
        NSString *algorithm = [key objectForKey:@"algorithm"];
        Class clazz = [key_classes() objectForKey:algorithm];
        if (clazz) {
            return [clazz getInstance:key];
        }
        NSAssert(false, @"symmetric key not support: %@", key);
        return nil;
    }
    // subclass
    return [[self alloc] initWithDictionary:key];
}

@end

@implementation MKMSymmetricKey (PersistentStore)

+ (nullable instancetype)loadKeyWithIdentifier:(NSString *)identifier {
    if (![self isEqual:[MKMSymmetricKey class]]) {
        // subclass
        NSAssert(false, @"override me!");
        return nil;
    }
    MKMSymmetricKey *key = nil;
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
