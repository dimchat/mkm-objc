//
//  MKMPrivateKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#include "MKMRSAPrivateKey.h"

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

- (MKMPublicKey *)publicKey {
    // implements in subclass
    return nil;
}

@end

static NSMutableDictionary<NSString *, Class> *key_classes(void) {
    static NSMutableDictionary<NSString *, Class> *classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = [[NSMutableDictionary alloc] init];
        // RSA
        [classes setObject:[MKMRSAPrivateKey class] forKey:ACAlgorithmRSA];
        [classes setObject:[MKMRSAPrivateKey class] forKey:@"SHA256withRSA"];
        [classes setObject:[MKMRSAPrivateKey class] forKey:@"RSA/ECB/PKCS1Padding"];
        // ECC
        // ...
    });
    return classes;
}

@implementation MKMPrivateKey (Runtime)

+ (void)registerClass:(Class)keyClass forAlgorithm:(NSString *)name {
    NSAssert([keyClass isSubclassOfClass:self], @"class error: %@", keyClass);
    if (keyClass) {
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
    NSAssert([key isKindOfClass:[NSDictionary class]],
             @"private key should be a dictionary: %@", key);
    if (![self isEqual:[MKMPrivateKey class]]) {
        // subclass
        NSAssert([self isSubclassOfClass:[MKMPrivateKey class]], @"key class error");
        return [[self alloc] initWithDictionary:key];
    }
    // create instance by subclass with algorithm name
    NSString *algorithm = [key objectForKey:@"algorithm"];
    Class clazz = [key_classes() objectForKey:algorithm];
    if (clazz) {
        return [clazz getInstance:key];
    }
    NSAssert(false, @"key algorithm not support: %@", algorithm);
    return nil;
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
