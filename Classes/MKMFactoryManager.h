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
//  MKMFactoryManager.h
//  MingKeMing
//
//  Created by Albert Moky on 2023/1/31.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <MingKeMing/MKMAddress.h>
#import <MingKeMing/MKMID.h>
#import <MingKeMing/MKMMeta.h>
#import <MingKeMing/MKMTai.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  General Factory for Accounts
 *  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 */
@protocol MKMGeneralFactory <NSObject>

#pragma mark Address

- (void)setAddressFactory:(id<MKMAddressFactory>)factory;
- (nullable id<MKMAddressFactory>)addressFactory;

- (id<MKMAddress>)generateAddressWithType:(MKMEntityType)network
                                     meta:(id<MKMMeta>)meta;

- (nullable id<MKMAddress>)createAddress:(NSString *)address;

- (nullable id<MKMAddress>)parseAddress:(nullable id)address;

#pragma mark ID

- (void)setIDFactory:(id<MKMIDFactory>)factory;
- (nullable id<MKMIDFactory>)idFactory;

- (id<MKMID>)generateIdentifierWithType:(MKMEntityType)network
                                   meta:(id<MKMMeta>)meta
                               terminal:(nullable NSString *)location;

- (id<MKMID>)createIdentifierWithName:(nullable NSString *)name
                              address:(id<MKMAddress>)main
                             terminal:(nullable NSString *)loc;

- (nullable id<MKMID>)parseIdentifier:(nullable id)identifier;

- (NSArray<id<MKMID>> *)convertIDList:(NSArray<id> *)members;
- (NSArray<NSString *> *)revertIDList:(NSArray<id<MKMID>> *)members;

#pragma mark Meta

- (void)setMetaFactory:(id<MKMMetaFactory>)factory forType:(MKMMetaType)version;
- (nullable id<MKMMetaFactory>)metaFactoryForType:(MKMMetaType)version;

- (MKMMetaType)metaType:(NSDictionary<NSString *, id> *)meta
           defaultValue:(MKMMetaType)aValue;

- (id<MKMMeta>)generateMetaWithType:(MKMMetaType)version
                                key:(id<MKMSignKey>)sKey
                               seed:(nullable NSString *)name;

- (id<MKMMeta>)createMetaWithType:(MKMMetaType)version
                              key:(id<MKMVerifyKey>)pKey
                             seed:(nullable NSString *)name
                      fingerprint:(nullable id<MKMTransportableData>)signature;

- (nullable id<MKMMeta>)parseMeta:(nullable id)meta;

#pragma mark Document

- (void)setDocumentFactory:(id<MKMDocumentFactory>)factory forType:(NSString *)type;
- (nullable id<MKMDocumentFactory>)documentFactoryForType:(NSString *)type;

- (nullable NSString *)documentType:(NSDictionary<NSString *, id> *)doc
                       defaultValue:(nullable NSString *)aValue;

- (id<MKMDocument>)createDocument:(id<MKMID>)identifier
                             type:(NSString *)type
                             data:(nullable NSString *)json
                        signature:(nullable id<MKMTransportableData>)ted;

- (nullable id<MKMDocument>)parseDocument:(nullable id)doc;

@end

#pragma mark -

@interface MKMGeneralFactory : NSObject <MKMGeneralFactory>

@end

@interface MKMFactoryManager : NSObject

@property(strong, nonatomic) id<MKMGeneralFactory> generalFactory;

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
