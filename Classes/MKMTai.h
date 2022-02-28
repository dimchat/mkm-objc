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

#import <MingKeMing/MKMDictionary.h>

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
- (nullable id)propertyForKey:(NSString *)key;

/**
 *  Update property with key and data
 *  (this will reset 'data' and 'signature')
 *
 * @param key - property name
 * @param value - property data
*/
- (void)setProperty:(nullable id)value forKey:(NSString *)key;

@end

//
//  Document types
//
#define MKMDocument_Visa     @"visa"      // for login/communication
#define MKMDocument_Profile  @"profile"   // for user info
#define MKMDocument_Bulletin @"bulletin"  // for group info

@protocol MKMID;

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
@protocol MKMDocument <MKMTAI>

/**
 *  Get document type
 */
@property (readonly, strong, nonatomic) NSString *type;

/**
 *  Get entity ID
 */
@property (readonly, strong, nonatomic) id<MKMID> ID;

/**
 *  Get sign time
 */
@property (readonly, strong, nonatomic) NSDate *time;

/**
 *  Get/set entity name
 */
@property (strong, nonatomic) NSString *name;  // properties getter/setter


@end

@protocol MKMDocumentFactory <NSObject>

/**
 *  Create document with data & signature loaded from local storage
 *
 * @param ID - entity ID
 * @param json - document data
 * @param base64 - document signature
 * @return Document
 */
- (__kindof id<MKMDocument>)createDocument:(id<MKMID>)ID data:(NSString *)json signature:(NSString *)base64;

/**
 *  Create a new empty document with entity ID
 *
 * @param ID - entity ID
 * @return Document
 */
- (__kindof id<MKMDocument>)createDocument:(id<MKMID>)ID;

/**
 *  Parse map object to entity document
 *
 * @param doc - info
 * @return Document
 */
- (nullable __kindof id<MKMDocument>)parseDocument:(NSDictionary *)doc;

@end

#ifdef __cplusplus
extern "C" {
#endif

id<MKMDocumentFactory> MKMDocumentGetFactory(NSString *type);
void MKMDocumentSetFactory(NSString *type, id<MKMDocumentFactory> factory);

__kindof id<MKMDocument> MKMDocumentNew(NSString *type, id<MKMID> ID);
__kindof id<MKMDocument> MKMDocumentCreate(NSString *type, id<MKMID> ID, NSString *data, NSString *signature);
__kindof id<MKMDocument> MKMDocumentParse(id doc);

NSString *MKMDocumentGetType(NSDictionary<NSString *, id> *doc);
id<MKMID> MKMDocumentGetID(NSDictionary<NSString *, id> *doc);
NSData * _Nullable MKMDocumentGetData(NSDictionary<NSString *, id> *doc);
NSData * _Nullable MKMDocumentGetSignature(NSDictionary<NSString *, id> *doc);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

#define MKMDocumentFromDictionary(dict)    MKMDocumentParse(dict)

#define MKMDocumentRegister(type, factory) MKMDocumentSetFactory(type, factory)

#pragma mark - Base Class

@interface MKMDocument : MKMDictionary <MKMDocument>

- (instancetype)initWithDictionary:(NSDictionary *)dict
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithID:(id<MKMID>)ID data:(NSString *)json signature:(NSString *)base64
NS_DESIGNATED_INITIALIZER;

// create a new empty document with entity ID & document type
- (instancetype)initWithID:(id<MKMID>)ID type:(NSString *)type
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
