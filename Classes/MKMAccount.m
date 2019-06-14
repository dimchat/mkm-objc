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

- (BOOL)verify:(const NSData *)data withSignature:(const NSData *)signature {
    // 1. get key for signature from meta
    const MKMMeta *meta = [self meta];
    MKMPublicKey *key = [meta key];
    // 2. verify with meta.key
    return [key verify:data withSignature:signature];
}

- (NSData *)encrypt:(const NSData *)plaintext {
    // 1. get key for encryption from profile
    MKMProfile *profile = [self profile];
    MKMPublicKey *key = [profile key];
    if (key == nil) {
        // 2. get key for encryption from meta
        const MKMMeta *meta = [self meta];
        // NOTICE: meta.key will never changed,
        //         so use profile.key to encrypt is the better way
        key = [meta key];
    }
    // 3. encrypt with profile.key
    return [key encrypt:plaintext];
}

@end
