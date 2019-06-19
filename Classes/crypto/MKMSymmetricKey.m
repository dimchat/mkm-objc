//
//  MKMSymmetricKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

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

@end

static NSMutableDictionary<NSString *, Class> *key_classes(void) {
    static NSMutableDictionary<NSString *, Class> *classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = [[NSMutableDictionary alloc] init];
        // AES
        [classes setObject:[MKMAESKey class] forKey:SCAlgorithmAES];
        // DES
        // ...
    });
    return classes;
}

@implementation MKMSymmetricKey (Runtime)

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
    if ([key isKindOfClass:[MKMSymmetricKey class]]) {
        // return SymmetricKey object directly
        return key;
    }
    NSAssert([key isKindOfClass:[NSDictionary class]],
             @"symmetric key should be a dictionary: %@", key);
    if (![self isEqual:[MKMSymmetricKey class]]) {
        // subclass
        NSAssert([self isSubclassOfClass:[MKMSymmetricKey class]], @"key class error");
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
