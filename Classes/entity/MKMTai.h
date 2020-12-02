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
//  MKMTai.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MKMVerifyKey;
@protocol MKMSignKey;

/**
 *  The Additional Information (Profile)
 *
 *      'Meta' is the information for entity which never changed,
 *          which contains the key for verify signature;
 *      'TAI' is the variable part(signed by meta.key's private key),
 *          which contains the key for asymmetric encryption.
 */
@protocol MKMTAI <MKMDictionary>

/**
 *  Check if signature matched
 */
@property (readonly, nonatomic, getter=isValid) BOOL valid;

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

/**
 *  Get all names for properties
 *
 * @return keys
 */
- (NSArray *)propertyKeys;

/**
 *  Get property data with key
 *
 * @param key - property name
 * @return property data
 */
- (nullable NSObject *)propertyForKey:(NSString *)key;

/**
 *  Update property with key and data
 *  (this will reset 'data' and 'signature')
 *
 * @param key - property name
 * @param value - property data
*/
- (void)setProperty:(nullable NSObject *)value forKey:(NSString *)key;

@end

@class MKMID;

/**
 *  User/Group Profile
 *  ~~~~~~~~~~~~~~~~~~
 *  This class is used to generate entity profile
 *
 *      data format: {
 *          ID: "EntityID",   // entity ID
 *          data: "{JSON}",   // data = json_encode(info)
 *          signature: "..."  // signature = sign(data, SK);
 *      }
 */
@protocol MKMDocument <MKMTAI, MKMDictionary>

/**
 *  Get document type
 */
@property (readonly, strong, nonatomic) NSString *type;

/**
 *  Get entity ID
 */
@property (readonly, strong, nonatomic) id<MKMID> ID;

/**
 *  Get/set entity name
 */
@property (strong, nonatomic) NSString *name;  // properties getter/setter


@end

//
//  Document types
//
#define MKMDocument_Any      @""
#define MKMDocument_Visa     @"visa"      // for login/communication
#define MKMDocument_Profile  @"profile"   // for user info
#define MKMDocument_Bulletin @"bulletin"  // for group info

#pragma mark -

@interface MKMDocument : MKMDictionary <MKMDocument>

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithID:(MKMID *)ID
                      data:(NSData *)json
                 signature:(NSData *)signature
NS_DESIGNATED_INITIALIZER;

// create a new empty profile with entity ID
- (instancetype)initWithID:(MKMID *)ID
NS_DESIGNATED_INITIALIZER;

@end

// create Document with data & signature loaded from local storage
#define MKMDocumentCreate(ID, t, d, CT)                                        \
            [MKMDocument create:(ID) type:(t) data:(d) signature:(CT)]         \
                                     /* EOF 'MKMDocumentCreate(ID, t, d, CT)' */

// new Document
#define MKMDocumentNew(ID, t)                                                  \
            [MKMDocument create:(ID) type:(t)]                                 \
                                               /* EOF 'MKMDocumentNew(ID, t)' */

// convert Dictionary to Document
#define MKMDocumentFromDictionary(doc)                                         \
            [MKMDocument parse:(doc)]                                          \
                                         /* EOF 'MKMMetaFromDictionary(meta)' */

#pragma mark - Creation

@protocol MKMDocumentFactory <NSObject>

- (id<MKMDocument>)createDocument:(id<MKMID>)ID type:(NSString *)type data:(NSData *)data signature:(NSData *)CT;

// create a new empty profile with entity ID
- (id<MKMDocument>)createDocument:(id<MKMID>)ID type:(NSString *)type;

- (nullable id<MKMDocument>)parseDocument:(NSDictionary *)doc;

@end

@interface MKMDocument (Creation)

+ (void)setFactory:(id<MKMDocumentFactory>)factory;

+ (id<MKMDocument>)create:(id<MKMID>)ID type:(NSString *)type data:(NSData *)data signature:(NSData *)CT;

// create a new empty profile with entity ID
+ (id<MKMDocument>)create:(id<MKMID>)ID type:(NSString *)type;

+ (nullable id<MKMDocument>)parse:(NSDictionary *)doc;

@end

NS_ASSUME_NONNULL_END
