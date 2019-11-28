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
//  MKMTai.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MKMEncryptKey;
@protocol MKMVerifyKey;
@protocol MKMSignKey;

@class MKMID;

/**
 *  The Additional Information (Profile)
 *
 *      'Meta' is the information for entity which never changed,
 *          which contains the key for verify signature;
 *      'TAI' is the variable part(signed by meta.key's private key),
 *          which contains the key for asymmetric encryption.
 */
@interface MKMTAI : MKMDictionary

/**
 *  Check if signature matched
 */
@property (readonly, nonatomic, getter=isValid) BOOL valid;

/**
 *  Get entity ID
 */
@property (readonly, strong, nonatomic) NSString *ID;

/**
 *  Get public key to encrypt message for user
 */
@property (readonly, strong, nonatomic, nullable) id<MKMEncryptKey> key;

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithID:(MKMID *)ID
                      data:(NSData *)json
                 signature:(NSData *)signature
NS_DESIGNATED_INITIALIZER;

// create a new empty profile with entity ID
- (instancetype)initWithID:(MKMID *)ID
NS_DESIGNATED_INITIALIZER;

#pragma mark Interfaces for profile properties

/**
 *  Get all keys for properties
 */
- (NSArray *)propertyKeys;

/**
 *  Get profile property data with key
 */
- (nullable NSObject *)propertyForKey:(NSString *)key;

/**
 *  Update profile property with data & key
 *  (this will reset data & signature)
 */
- (void)setProperty:(nullable NSObject *)value forKey:(NSString *)key;

#pragma mark Data Signature

/**
 *  Verify 'data' and 'signature', if OK, refresh properties from 'data'
 *
 * @param PK - public key in meta.key
 * @return true on signature matched
 */
- (BOOL)verify:(id<MKMVerifyKey>)PK;

/**
 *  Encode properties to 'data' and sign it to 'signature'
 *
 * @param SK - private key match meta.key
 * @return signature
 */
- (NSData *)sign:(id<MKMSignKey>)SK;

@end

NS_ASSUME_NONNULL_END
