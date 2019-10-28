//
//  MKMPublicKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"

#import "MKMPrivateKey.h"
#import "MKMRSAPublicKey.h"

#import "MKMPublicKey.h"

@implementation MKMPublicKey

- (BOOL)isMatch:(MKMPrivateKey *)SK {
    // 1. if the SK has the same public key, return YES
    if ([SK.publicKey isEqual:self]) {
        return YES;
    }
    // 2. try to verify the SK's signature
    static NSString *promise = @"Moky loves May Lee forever!";
    NSData *data = [promise dataUsingEncoding:NSUTF8StringEncoding];
    NSData *signature = [SK sign:data];
    return [self verify:data withSignature:signature];
}

- (NSData *)encrypt:(NSData *)plaintext {
    NSAssert(false, @"override me!");
    return nil;
}

- (BOOL)verify:(NSData *)data withSignature:(NSData *)signature {
    NSAssert(false, @"override me!");
    return NO;
}

@end

static NSMutableDictionary<NSString *, Class> *key_classes(void) {
    static NSMutableDictionary<NSString *, Class> *classes = nil;
    SingletonDispatchOnce(^{
        classes = [[NSMutableDictionary alloc] init];
        // RSA
        [classes setObject:[MKMRSAPublicKey class] forKey:ACAlgorithmRSA];
        [classes setObject:[MKMRSAPublicKey class] forKey:@"SHA256withRSA"];
        [classes setObject:[MKMRSAPublicKey class] forKey:@"RSA/ECB/PKCS1Padding"];
        // ECC
        // ...
    });
    return classes;
}

@implementation MKMPublicKey (Runtime)

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
    if ([key isKindOfClass:[MKMPublicKey class]]) {
        // return PublicKey object directly
        return key;
    }
    NSAssert([key isKindOfClass:[NSDictionary class]], @"public key error: %@", key);
    if ([self isEqual:[MKMPublicKey class]]) {
        // create instance by subclass with key algorithm
        NSString *algorithm = [key objectForKey:@"algorithm"];
        Class clazz = [key_classes() objectForKey:algorithm];
        if (clazz) {
            return [clazz getInstance:key];
        }
        NSAssert(false, @"public key not support: %@", key);
        return nil;
    }
    // subclass
    return [[self alloc] initWithDictionary:key];
}

@end

@implementation MKMPublicKey (PersistentStore)

+ (nullable instancetype)loadKeyWithIdentifier:(NSString *)identifier {
    if (![self isEqual:[MKMPublicKey class]]) {
        // subclass
        NSAssert(false, @"override me!");
        return nil;
    }
    MKMPublicKey *key = nil;
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
