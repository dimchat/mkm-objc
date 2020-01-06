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
//  MKMUser.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMProfile.h"

#import "MKMUser.h"

@implementation MKMUser

- (nullable id<MKMUserDataSource>)dataSource {
    return (id<MKMUserDataSource>)[super dataSource];
}

- (id<MKMVerifyKey>)metaKey {
    MKMMeta *meta = [self meta];
    // if meta not exists, user won't be created
    NSAssert(meta, @"failed to get meta for user: %@", _ID);
    return [meta key];
}

- (nullable id<MKMEncryptKey>)profileKey {
    MKMProfile *profile = [self profile];
    NSAssert(!profile || [profile isValid], @"profile not valid: %@", profile);
    return [profile key];
}

// NOTICE: meta.key will never changed, so use profile.key to encrypt
//         is the better way
- (nullable id<MKMEncryptKey>)encryptKey {
    id<MKMEncryptKey> key;
    // 0. get key from delegate
    key = [self.dataSource publicKeyForEncryption:_ID];
    if (key) {
        return key;
    }
    // 1. get key from profile
    key = [self profileKey];
    if (key) {
        return key;
    }
    // 2. get key from meta
    id<MKMVerifyKey> mKey = [self metaKey];
    if ([mKey conformsToProtocol:@protocol(MKMEncryptKey)]) {
        return (id<MKMEncryptKey>)mKey;
    }
    NSAssert(false, @"failed to get encrypt key for user: %@", _ID);
    return nil;
}

// NOTICE: I suggest using the private key paired with meta.key to sign message
//         so here should return the meta.key
- (nullable NSArray<id<MKMVerifyKey>> *)verifyKeys {
    NSArray<id<MKMVerifyKey>> *keys;
    // 0. get keys from delegate
    keys = [self.dataSource publicKeysForVerification:_ID];
    if ([keys count] > 0) {
        return keys;
    }
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    /*
    // 1. get key from profile
    NSObject *pKey = [self profileKey];
    if ([pKey conformsToProtocol:@protocol(MKMVerifyKey)]) {
        [mArray addObject:pKey];
    }
     */
    // 2. get key from meta
    id<MKMVerifyKey> mKey = [self metaKey];
    NSAssert(mKey, @"failed to get meta key for user: %@", _ID);
    [mArray addObject:mKey];
    return mArray;
}

- (BOOL)verify:(NSData *)data withSignature:(NSData *)signature {
    NSArray<id<MKMVerifyKey>> *keys = [self verifyKeys];
    for (id<MKMVerifyKey> key in keys) {
        if ([key verify:data withSignature:signature]) {
            return YES;
        }
    }
    return NO;
}

- (NSData *)encrypt:(NSData *)plaintext {
    id<MKMEncryptKey> key = [self encryptKey];
    NSAssert(key, @"failed to get encrypt key for user: %@", _ID);
    return [key encrypt:plaintext];
}

@end

@implementation MKMUser (Local)

- (NSString *)debugDescription {
    NSString *desc = [super debugDescription];
    NSDictionary *dict = [[desc data] jsonDictionary];
    NSMutableDictionary *info = [dict mutableCopy];
    [info setObject:@(self.contacts.count) forKey:@"contacts"];
    return [info jsonString];
}

- (NSArray<MKMID *> *)contacts {
    NSAssert(self.dataSource, @"user data source not set yet");
    NSArray *list = [self.dataSource contactsOfUser:_ID];
    return [list copy];
}

- (BOOL)existsContact:(MKMID *)ID {
    NSAssert(self.dataSource, @"user data source not set yet");
    NSArray<MKMID *> *contacts = [self contacts];
    NSInteger count = [contacts count];
    if (count <= 0) {
        return NO;
    }
    MKMID *contact;
    while (--count >= 0) {
        contact = [contacts objectAtIndex:count];
        if ([contact isEqual:ID]) {
            return YES;
        }
    }
    return NO;
}

- (nullable id<MKMSignKey>)signKey {
    return [self.dataSource privateKeyForSignature:_ID];
}

- (nullable NSArray<id<MKMDecryptKey>> *)decryptKeys {
    return [self.dataSource privateKeysForDecryption:_ID];
}

- (NSData *)sign:(NSData *)data {
    id<MKMSignKey> key = [self signKey];
    NSAssert(key, @"failed to get sign key for user: %@", _ID);
    return [key sign:data];
}

- (nullable NSData *)decrypt:(NSData *)ciphertext {
    NSArray<id<MKMDecryptKey>> *keys = [self decryptKeys];
    NSAssert([keys count] > 0, @"failed to get decrypt keys for user: %@", _ID);
    NSData *plaintext = nil;
    for (id<MKMDecryptKey> key in keys) {
        @try {
            plaintext = [key decrypt:ciphertext];
            if ([plaintext length] > 0) {
                return plaintext;
            }
        } @catch (NSException *exception) {
            // this key not match, try next one
        } @finally {
            //
        }
    }
    return nil;
}

@end
