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

- (instancetype)init {
    self = [self initWithAlgorithm:ACAlgorithmRSA];
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if ([self isMemberOfClass:[MKMPrivateKey class]]) {
        // create instance by subclass with algorithm
        NSString *algorithm = [keyInfo objectForKey:@"algorithm"];
        Class clazz = [[self class] classForAlgorithm:algorithm];
        if (clazz) {
            self = [[clazz alloc] initWithDictionary:keyInfo];
        } else {
            NSAssert(false, @"algorithm not support: %@", algorithm);
            self = nil;
        }
    } else if (self = [super initWithDictionary:keyInfo]) {
        //
    }
    return self;
}

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

@implementation MKMPrivateKey (Runtime)

static MKMCryptographyKeyMap *s_privateKeyClasses = nil;

+ (MKMCryptographyKeyMap *)keyClasses {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MKMCryptographyKeyMap *map = [[NSMutableDictionary alloc] init];
        // RSA
        [map setObject:[MKMRSAPrivateKey class] forKey:ACAlgorithmRSA];
        // ECC
        // ...
        s_privateKeyClasses = map;
    });
    return s_privateKeyClasses;
}

@end
