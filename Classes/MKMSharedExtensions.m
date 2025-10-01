// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2025 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2025 Albert Moky
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
//  MKMSharedExtensions.m
//  MingKeMing
//
//  Created by Albert Moky on 2025/10/1.
//  Copyright © 2025 DIM Group. All rights reserved.
//

#import "MKMSharedExtensions.h"

static NSData *promise = nil;

NSData *MKMakePromise(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *words = @"Moky loves May Lee forever!";
        promise = [words dataUsingEncoding:NSUTF8StringEncoding];
    });
    return promise;
}

BOOL MKMatchAsymmetricKeys(id<MKSignKey> sKey, id<MKVerifyKey> pKey) {
    NSData *data = MKMakePromise();
    NSData *signature = [sKey sign:data];
    return [pKey verify:data withSignature:signature];
}

BOOL MKMatchSymmetricKeys(id<MKEncryptKey> encKey, id<MKDecryptKey> decKey) {
    NSMutableDictionary<NSString *, id> *extra = [[NSMutableDictionary alloc] init];
    NSData *data = MKMakePromise();
    NSData *ciphertext = [encKey encrypt:data extra:extra];
    NSData *plaintext = [decKey decrypt:ciphertext params:extra];
    return [data isEqualToData:plaintext];
}

@implementation MKSharedCryptoExtensions

static MKSharedCryptoExtensions *s_crypto_extension = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_crypto_extension = [[self alloc] init];
    });
    return s_crypto_extension;
}

- (id<MKSymmetricKeyHelper>)symmetricHelper {
    MKCryptoExtensions *ext = [MKCryptoExtensions sharedInstance];
    return [ext symmetricHelper];
}

- (void)setSymmetricHelper:(id<MKSymmetricKeyHelper>)symmetricHelper {
    MKCryptoExtensions *ext = [MKCryptoExtensions sharedInstance];
    [ext setSymmetricHelper:symmetricHelper];
}

- (id<MKPrivateKeyHelper>)privateHelper {
    MKCryptoExtensions *ext = [MKCryptoExtensions sharedInstance];
    return [ext privateHelper];
}

- (void)setPrivateHelper:(id<MKPrivateKeyHelper>)privateHelper {
    MKCryptoExtensions *ext = [MKCryptoExtensions sharedInstance];
    [ext setPrivateHelper:privateHelper];
}

- (id<MKPublicKeyHelper>)publicHelper {
    MKCryptoExtensions *ext = [MKCryptoExtensions sharedInstance];
    return [ext publicHelper];
}

- (void)setPublicHelper:(id<MKPublicKeyHelper>)publicHelper {
    MKCryptoExtensions *ext = [MKCryptoExtensions sharedInstance];
    [ext setPublicHelper:publicHelper];
}

@end

#pragma mark -

@implementation MKSharedFormatExtensions

static MKSharedFormatExtensions *s_format_extension = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_format_extension = [[self alloc] init];
    });
    return s_format_extension;
}

- (id<MKTransportableDataHelper>)tedHelper {
    MKFormatExtensions *ext = [MKFormatExtensions sharedInstance];
    return [ext tedHelper];
}

- (void)setTedHelper:(id<MKTransportableDataHelper>)tedHelper {
    MKFormatExtensions *ext = [MKFormatExtensions sharedInstance];
    [ext setTedHelper:tedHelper];
}

- (id<MKPortableNetworkFileHelper>)pnfHelper {
    MKFormatExtensions *ext = [MKFormatExtensions sharedInstance];
    return [ext pnfHelper];
}

- (void)setPnfHelper:(id<MKPortableNetworkFileHelper>)pnfHelper {
    MKFormatExtensions *ext = [MKFormatExtensions sharedInstance];
    [ext setPnfHelper:pnfHelper];
}

@end

#pragma mark -

@implementation MKMSharedAccountExtensions

static MKMSharedAccountExtensions *s_account_extension = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_account_extension = [[self alloc] init];
    });
    return s_account_extension;
}

- (id<MKMAddressHelper>)addressHelper {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    return [ext addressHelper];
}

- (void)setAddressHelper:(id<MKMAddressHelper>)addressHelper {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    [ext setAddressHelper:addressHelper];
}

- (id<MKMIdentifierHelper>)idHelper {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    return [ext idHelper];
}

- (void)setIdHelper:(id<MKMIdentifierHelper>)idHelper {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    [ext setIdHelper:idHelper];
}

- (id<MKMMetaHelper>)metaHelper {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    return [ext metaHelper];
}

- (void)setMetaHelper:(id<MKMMetaHelper>)metaHelper {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    [ext setMetaHelper:metaHelper];
}

- (id<MKMDocumentHelper>)docHelper {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    return [ext docHelper];
}

- (void)setDocHelper:(id<MKMDocumentHelper>)docHelper {
    MKMAccountExtensions *ext = [MKMAccountExtensions sharedInstance];
    [ext setDocHelper:docHelper];
}

@end
