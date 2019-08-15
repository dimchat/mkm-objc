//
//  MKMUser.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMProfile.h"

#import "MKMUser.h"

@implementation MKMUser

- (MKMPublicKey *)metaKey {
    MKMMeta *meta = [self meta];
    return [meta key];
}

- (nullable MKMPublicKey *)profileKey {
    MKMProfile *profile = [self profile];
    return [profile key];
}

- (nullable MKMProfile *)profile {
    MKMProfile *tai = [super profile];
    if (!tai || [tai isValid]) {
        // no need to verify
        return tai;
    }
    // try to verify with meta.key
    MKMPublicKey *key = [self metaKey];
    if ([tai verify:key]) {
        // signature correct
        return tai;
    }
    // profile error? continue to process by subclass
    return tai;
}

- (BOOL)verify:(NSData *)data withSignature:(NSData *)signature {
    MKMPublicKey *key;
    /*
    // 1. get public key from profile
    key = [self profileKey];
    if ([key verify:data withSignature:signature]) {
        return YES;
    }
     */
    // 2. get public key from meta
    key = [self metaKey];
    NSAssert(key, @"failed to get verify key for: %@", _ID);
    // 3. verify it
    return [key verify:data withSignature:signature];
}

- (NSData *)encrypt:(NSData *)plaintext {
    // 1. get key for encryption from profile
    MKMPublicKey *key = [self profileKey];
    if (!key) {
        // 2. get key for encryption from meta
        //    NOTICE: meta.key will never changed, so use profile.key to encrypt
        //            is the better way
        key = [self metaKey];
    }
    NSAssert(key, @"failed to get encrypt key for: %@", _ID);
    // 3. encrypt it
    return [key encrypt:plaintext];
}

@end
