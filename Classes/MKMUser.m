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

#pragma mark Local User

- (NSString *)debugDescription {
    NSString *desc = [super debugDescription];
    NSDictionary *dict = [[desc data] jsonDictionary];
    NSMutableDictionary *info = [dict mutableCopy];
    [info setObject:@(self.contacts.count) forKey:@"contacts"];
    return [info jsonString];
}

- (NSData *)sign:(NSData *)data {
    NSAssert(self.dataSource, @"user data source not set yet");
    MKMPrivateKey *key = [self.dataSource privateKeyForSignatureOfUser:_ID];
    NSAssert(key, @"failed to get private key for signature: %@", _ID);
    return [key sign:data];
}

- (nullable NSData *)decrypt:(NSData *)ciphertext {
    NSAssert(self.dataSource, @"user data source not set yet");
    NSArray<MKMPrivateKey *> *keys = [self.dataSource privateKeysForDecryptionOfUser:_ID];
    NSData *plaintext = nil;
    for (MKMPrivateKey *key in keys) {
        plaintext = [key decrypt:ciphertext];
        if (plaintext != nil) {
            // OK!
            break;
        }
    }
    return plaintext;
}

#pragma mark Contacts of Local User

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

@end
