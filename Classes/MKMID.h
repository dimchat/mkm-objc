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
//  MKMID.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <MingKeMing/MKMAddress.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  ID for entity (User/Group)
 *
 *      data format: "name@address[/terminal]"
 *
 *      fileds:
 *          name     - entity name, the seed of fingerprint to build address
 *          address  - a string to identify an entity
 *          terminal - entity login resource(device), OPTIONAL
 */
@protocol MKMID <MKMString>

@property (readonly, strong, nonatomic, nullable) NSString *name;
@property (readonly, strong, nonatomic) __kindof id<MKMAddress> address;
@property (readonly, strong, nonatomic, nullable) NSString *terminal;

@property (readonly, nonatomic) MKMEntityType type; // Network ID

- (BOOL)isBroadcast;

- (BOOL)isUser;
- (BOOL)isGroup;

@end

#pragma mark - ID Factory

@protocol MKMMeta;

@protocol MKMIDFactory <NSObject>

/**
 *  Generate ID
 *
 * @param meta - meta info
 * @param network - ID.type
 * @param location - ID.terminal
 * @return ID
 */
- (id<MKMID>)generateIdentifierWithMeta:(id<MKMMeta>)meta
                                   type:(MKMEntityType)network
                               terminal:(nullable NSString *)location;

/**
 *  Create ID
 *
 * @param name     - ID.name
 * @param address  - ID.address
 * @param location - ID.terminal
 * @return ID
 */
- (id<MKMID>)createIdentifierWithName:(nullable NSString *)name
                              address:(id<MKMAddress>)address
                             terminal:(nullable NSString *)location;

/**
 *  Parse string object to ID
 *
 * @param identifier - ID string
 * @return ID
 */
- (nullable id<MKMID>)parseIdentifier:(NSString *)identifier;

@end

#ifdef __cplusplus
extern "C" {
#endif

_Nullable id<MKMIDFactory> MKMIDGetFactory(void);
void MKMIDSetFactory(id<MKMIDFactory> factory);

id<MKMID> MKMIDGenerate(id<MKMMeta> meta,
                        MKMEntityType network,
                        NSString * _Nullable terminal);

id<MKMID> MKMIDCreate(NSString * _Nullable name,
                      id<MKMAddress> address,
                      NSString * _Nullable terminal);

_Nullable id<MKMID> MKMIDParse(_Nullable id identifier);

// Broadcast IDs
id<MKMID> MKMAnyone(void);
id<MKMID> MKMEveryone(void);
id<MKMID> MKMFounder(void);  // DIM Founder

/**
 *  Convert ID list from string array
 */
NSArray<id<MKMID>> *MKMIDConvert(NSArray<id> *members);

/**
 *  Revert ID list to string array
 */
NSArray<NSString *> *MKMIDRevert(NSArray<id<MKMID>> *members);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

#pragma mark - Base Class

@interface MKMID : MKMString <MKMID>

/**
 *  Initialize an ID with string form "name@address[/terminal]"
 *
 * @param string - ID string
 * @param seed - username
 * @param address - hash(fingerprint)
 * @param location - login point (optional)
 * @return ID object
 */
- (instancetype)initWithString:(NSString *)string
                          name:(nullable NSString *)seed
                       address:(id<MKMAddress>)address
                      terminal:(nullable NSString *)location
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
