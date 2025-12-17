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

#import <MingKeMing/MKDictionary.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKTransportableData;

@protocol MKVerifyKey;
@protocol MKSignKey;

/**
 *  The Additional Information (Profile)
 *
 *      'Meta' is the information for entity which never changed,
 *          which contains the key for verify signature;
 *      'TAI' is the variable part (signed by meta.key's private key),
 *          which could contain a public key for asymmetric encryption.
 */
@protocol MKMTAI

/**
 *  Check if signature matched
 */
@property (readonly, nonatomic, getter=isValid) BOOL valid;

#pragma mark signature

/**
 *  Verify 'data' and 'signature', if OK, refresh properties from 'data'
 *
 * @param PK - public key in meta.key
 * @return true on signature matched
 */
- (BOOL)verify:(id<MKVerifyKey>)PK;

/**
 *  Encode properties to 'data' and sign it to 'signature'
 *
 * @param SK - private key match meta.key
 * @return signature, nil on error
 */
- (nullable NSData *)sign:(id<MKSignKey>)SK;

#pragma mark properties

/**
 *  Get all properties
 *
 * @return properties, null on invalid
 */
@property (readonly, strong, nonatomic, nullable) __kindof NSDictionary *properties;

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

#pragma mark -

@protocol MKMID;

/**
 *  User/Group Profile
 *  ~~~~~~~~~~~~~~~~~~
 *  This class is used to generate entity profile
 *
 *      data format: {
 *          "did"       : "EntityID",        // entity ID
 *          "type"      : "visa",            // "bulletin", ...
 *          "data"      : "{JSON}",          // data = json_encode(info)
 *          "signature" : "{BASE64_ENCODE}"  // signature = sign(data, SK);
 *      }
 */
@protocol MKMDocument <MKDictionary, MKMTAI>

/*
 *  Get entity ID
 */
//@property (readonly, strong, nonatomic) id<MKMID> identifier;

#pragma mark Properties getter/setter

/**
 *  Get sign time
 */
@property (readonly, strong, nonatomic, nullable) NSDate *time;

/*
 *  Get/set entity name
 */
//@property (strong, nonatomic, nullable) NSString *name;


@end

@protocol MKMDocumentFactory <NSObject>

/**
 *  1. Create document with data & signature loaded from local storage
 *  2. Create a new empty document with type
 *
 * @param json - document data
 * @param sig  - document signature
 * @return Document
 */
- (__kindof id<MKMDocument>)createDocumentWithData:(nullable NSString *)json
                                         signature:(nullable id<MKTransportableData>)sig;

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

_Nullable id<MKMDocumentFactory> MKMDocumentGetFactory(NSString *type);
void MKMDocumentSetFactory(NSString *type, id<MKMDocumentFactory> factory);

// Create new empty dpcument
__kindof id<MKMDocument> MKMDocumentNew(NSString *type);

// Create from stored info
__kindof id<MKMDocument> MKMDocumentCreate(NSString *type,
                                           NSString * data,
                                           id<MKTransportableData> signature);

_Nullable __kindof id<MKMDocument> MKMDocumentParse(_Nullable id doc);

#pragma mark Conveniences

NSMutableArray<id<MKMDocument>> *MKMDocumentConvert(NSArray<id> *array);

NSMutableArray<NSDictionary *> *MKMDocumentRevert(NSArray<id<MKMDocument>> *documents);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
