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
//  MKMUser.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/23.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMUser : MKMEntity

/**
 *  Verify data with signature, use meta.key
 *
 * @param data - message data
 * @param signature - message signature
 * @return true on correct
 */
- (BOOL)verify:(NSData *)data withSignature:(NSData *)signature;

/**
 *  Encrypt data, try profile.key first, if not found, use meta.key
 *
 * @param plaintext - message data
 * @return encrypted data
 */
- (NSData *)encrypt:(NSData *)plaintext;

#pragma mark Local User

@property (readonly, copy, nonatomic) NSArray<MKMID *> *contacts;

- (BOOL)existsContact:(MKMID *)ID;

/**
 *  Sign data with user's private key
 *
 * @param data - message data
 * @return signature
 */
- (NSData *)sign:(NSData *)data;

/**
 *  Decrypt data with user's private key
 *
 * @param ciphertext - encrypted data
 * @return plain text
 */
- (nullable NSData *)decrypt:(NSData *)ciphertext;

@end

#pragma mark - User Data Source

@protocol MKMUserDataSource <MKMEntityDataSource>

/**
 *  Get user's private key
 *
 * @param user - user ID
 * @return private key
 */
- (nullable MKMPrivateKey *)privateKeyForSignatureOfUser:(MKMID *)user;

/**
 *  Get user's private keys for decryption
 *
 * @param user - user ID
 * @return private key
 */
- (nullable NSArray<MKMPrivateKey *> *)privateKeysForDecryptionOfUser:(MKMID *)user;

/**
 *  Get contacts list
 *
 * @param user - user ID
 * @return contacts list (ID)
 */
- (nullable NSArray<MKMID *> *)contactsOfUser:(MKMID *)user;

@end

NS_ASSUME_NONNULL_END
