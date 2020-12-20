// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
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

#import "MKMDataParser.h"

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"
#import "MKMMeta.h"
#import "MKMProfile.h"

#import "MKMUser.h"

@implementation MKMUser

- (BOOL)verify:(NSData *)data withSignature:(NSData *)signature {
    // NOTICE: I suggest using the private key paired with meta.key to sign message
    //         so here should return the meta.key
    NSArray<id<MKMVerifyKey>> *keys = [self.dataSource publicKeysForVerification:_ID];
    for (id<MKMVerifyKey> key in keys) {
        if ([key verify:data withSignature:signature]) {
            // matched!
            return YES;
        }
    }
    return NO;
}

- (NSData *)encrypt:(NSData *)plaintext {
    // NOTICE: meta.key will never changed, so use profile.key to encrypt
    //         is the better way
    id<MKMEncryptKey> key = [self.dataSource publicKeyForEncryption:_ID];
    NSAssert(key, @"failed to get encrypt key for user: %@", _ID);
    return [key encrypt:plaintext];
}

@end

@implementation MKMUser (Local)

- (NSString *)debugDescription {
    NSString *desc = [super debugDescription];
    NSDictionary *dict = MKMJSONDecode(MKMUTF8Encode(desc));
    NSMutableDictionary *info;
    if ([dict isKindOfClass:[NSMutableDictionary class]]) {
        info = (NSMutableDictionary *)dict;
    } else {
        info = [dict mutableCopy];
    }
    [info setObject:@(self.contacts.count) forKey:@"contacts"];
    return MKMUTF8Decode(MKMJSONEncode(info));
}

- (NSArray<id<MKMID>> *)contacts {
    NSAssert(self.dataSource, @"user data source not set yet");
    return [self.dataSource contactsOfUser:_ID];
}

- (NSData *)sign:(NSData *)data {
    // NOTICE: I suggest use the private key which paired to visa.key
    //         to sign message
    id<MKMSignKey> key = [self.dataSource privateKeyForSignature:_ID];
    NSAssert(key, @"failed to get sign key for user: %@", _ID);
    return [key sign:data];
}

- (nullable NSData *)decrypt:(NSData *)ciphertext {
    // NOTICE: if you provide a public key in visa for encryption
    //         here you should return the private key paired with visa.key
    NSArray<id<MKMDecryptKey>> *keys = [self.dataSource privateKeysForDecryption:_ID];
    NSAssert([keys count] > 0, @"failed to get decrypt keys for user: %@", _ID);
    NSData *plaintext = nil;
    for (id<MKMDecryptKey> key in keys) {
        // try decrypting it with each private key
        @try {
            plaintext = [key decrypt:ciphertext];
            if ([plaintext length] > 0) {
                // OK!
                return plaintext;
            }
        } @catch (NSException *exception) {
            // this key not match, try next one
        }
    }
    // decryption failed
    return nil;
}

@end

@implementation MKMUser (Visa)

- (nullable id<MKMVisa>)signVisa:(id<MKMVisa>)visa {
    if (![_ID isEqual:visa.ID]) {
        // visa ID not match
        return nil;
    }
    id<MKMSignKey> key = [self.dataSource privateKeyForVisaSignature:_ID];
    NSAssert(key, @"failed to get visa sign key for user: %@", _ID);
    [visa sign:key];
    return visa;
}

- (BOOL)verifyVisa:(id<MKMVisa>)visa {
    if (![_ID isEqual:visa.ID]) {
        // visa ID not match
        return NO;
    }
    // if meta not exists, user won't be created
    id<MKMVerifyKey> key = [self.meta key];
    NSAssert(key, @"failed to get verify key for visa: %@", _ID);
    return [visa verify:key];
}

@end
