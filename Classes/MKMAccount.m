//
//  MKMAccount.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMPublicKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMProfile.h"

#import "MKMAccount.h"

@implementation MKMAccount

- (BOOL)verify:(NSData *)data withSignature:(NSData *)signature {
    // 1. get key for signature from meta
    MKMPublicKey *key = [self metaKey];
    // 2. verify with meta.key
    return [key verify:data withSignature:signature];
}

- (NSData *)encrypt:(NSData *)plaintext {
    // 1. get key for encryption from profile
    MKMPublicKey *key = [self profileKey];
    if (key == nil) {
        // 2. get key for encryption from meta
        //    NOTICE: meta.key will never changed, so use profile.key to encrypt is the better way
        key = [self metaKey];
    }
    // 3. encrypt with profile.key
    return [key encrypt:plaintext];
}

- (MKMPublicKey *)metaKey {
    MKMMeta *meta = [self meta];
    return [meta key];
}

- (MKMPublicKey *)profileKey {
    MKMProfile *profile = [self profile];
    return [profile key];
}

- (MKMProfile *)profile {
    MKMProfile *tao = [super profile];
    if (!tao) {
        return nil;
    }
    // try to verify with meta.key
    MKMPublicKey *key = [self metaKey];
    if ([tao verify:key]) {
        // signature correct
        return tao;
    }
    // profile error
    return tao;
}

@end
