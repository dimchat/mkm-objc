// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  MKMAccountHelpers.h
//  MingKeMing
//
//  Created by Albert Moky on 2023/1/31.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <MingKeMing/MKMEntityType.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKTransportableData;

@protocol MKSignKey;
@protocol MKVerifyKey;

@protocol MKMAddress;
@protocol MKMAddressFactory;

@protocol MKMID;
@protocol MKMIDFactory;

@protocol MKMMeta;
@protocol MKMMetaFactory;

@protocol MKMDocument;
@protocol MKMDocumentFactory;

@protocol MKMAddressHelper <NSObject>

- (void)setAddressFactory:(id<MKMAddressFactory>)factory;
- (nullable id<MKMAddressFactory>)getAddressFactory;

- (__kindof id<MKMAddress>)generateAddress:(MKMEntityType)network
                                  withMeta:(id<MKMMeta>)meta;

- (nullable __kindof id<MKMAddress>)parseAddress:(nullable id)address;

@end

@protocol MKMIdentifierHelper <NSObject>

- (void)setIdentifierFactory:(id<MKMIDFactory>)factory;
- (nullable id<MKMIDFactory>)getIdentifierFactory;

- (id<MKMID>)createIdentifierWithName:(nullable NSString *)name
                              address:(id<MKMAddress>)address
                             terminal:(nullable NSString *)location;

- (id<MKMID>)generateIdentifier:(MKMEntityType)network
                       withMeta:(id<MKMMeta>)meta
                       terminal:(nullable NSString *)location;

- (nullable id<MKMID>)parseIdentifier:(nullable id)identifier;

@end

@protocol MKMMetaHelper <NSObject>

- (void)setMetaFactory:(id<MKMMetaFactory>)factory
               forType:(NSString *)type;
- (nullable id<MKMMetaFactory>)getMetaFactory:(NSString *)type;

- (__kindof id<MKMMeta>)generateMetaWithKey:(id<MKSignKey>)SK
                                       seed:(nullable NSString *)name
                                    forType:(NSString *)type;

- (__kindof id<MKMMeta>)createMetaWithKey:(id<MKVerifyKey>)PK
                                     seed:(nullable NSString *)name
                              fingerprint:(nullable id<MKTransportableData>)sig
                                  forType:(NSString *)type;

- (nullable __kindof id<MKMMeta>)parseMeta:(nullable id)meta;

@end

@protocol MKMDocumentHelper <NSObject>

- (void)setDocumentFactory:(id<MKMDocumentFactory>)factory
                   forType:(NSString *)type;
- (nullable id<MKMDocumentFactory>)getDocumentFactory:(NSString *)type;

- (__kindof id<MKMDocument>)createDocument:(id<MKMID>)did
                                      data:(nullable NSString *)json
                                 signature:(nullable id<MKTransportableData>)sig
                                   forType:(NSString *)type;

- (nullable __kindof id<MKMDocument>)parseDocument:(nullable id)doc;

@end

#pragma mark - Account FactoryManager

@interface MKMAccountExtensions : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic, nullable) id<MKMAddressHelper> addressHelper;

@property (strong, nonatomic, nullable) id<MKMIdentifierHelper> idHelper;

@property (strong, nonatomic, nullable) id<MKMMetaHelper> metaHelper;

@property (strong, nonatomic, nullable) id<MKMDocumentHelper> docHelper;

@end

NS_ASSUME_NONNULL_END
