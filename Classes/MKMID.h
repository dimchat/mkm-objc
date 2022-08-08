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

@property (readonly, nonatomic) UInt8 type; // Network ID

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
 * @param type - ID.type
 * @param loc - ID.terminal
 * @return ID
 */
- (__kindof id<MKMID>)generateID:(id<MKMMeta>)meta
                         network:(UInt8)type
                        terminal:(nullable NSString *)loc;

/**
 *  Create ID
 *
 * @param name     - ID.name
 * @param address  - ID.address
 * @param loc - ID.terminal
 * @return ID
 */
- (__kindof id<MKMID>)createID:(nullable NSString *)name
                       address:(id<MKMAddress>)address
                      terminal:(nullable NSString *)loc;

/**
 *  Parse string object to ID
 *
 * @param identifier - ID string
 * @return ID
 */
- (nullable __kindof id<MKMID>)parseID:(NSString *)identifier;

@end

#ifdef __cplusplus
extern "C" {
#endif

__kindof id<MKMIDFactory> MKMIDGetFactory(void);
void MKMIDSetFactory(id<MKMIDFactory> factory);

__kindof id<MKMID> MKMIDGenerate(id<MKMMeta> meta, UInt8 network, NSString * _Nullable terminal);
__kindof id<MKMID> MKMIDCreate(NSString * _Nullable name, id<MKMAddress> address, NSString * _Nullable terminal);
__kindof id<MKMID> MKMIDParse(id identifier);

__kindof id<MKMID> MKMAnyone(void);
__kindof id<MKMID> MKMEveryone(void);

__kindof id<MKMID> MKMFounder(void);  // DIM Founder

/**
 *  Convert ID list from string array
 */
NSArray<__kindof id<MKMID>> *MKMIDConvert(NSArray<NSString *> *members);

/**
 *  Revert ID list to string array
 */
NSArray<NSString *> *MKMIDRevert(NSArray<id<MKMID>> *members);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

#define MKMIDFromString(S)   MKMIDParse(S)

#define MKMIDIsUser(ID)      [(ID) isUser]
#define MKMIDIsGroup(ID)     [(ID) isGroup]
#define MKMIDIsBroadcast(ID) [(ID) isBroadcast]

#pragma mark - Base Classes

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

- (instancetype)initWithName:(NSString *)seed
                     address:(id<MKMAddress>)address
                    terminal:(NSString *)location;

/**
 *  Default ID form (name@address)
 */
- (instancetype)initWithName:(NSString *)seed
                     address:(id<MKMAddress>)address;

/**
 *  For ID without name(only contains address), likes BTC/ETH/...
 */
- (instancetype)initWithAddress:(id<MKMAddress>)addr;

@end

@interface MKMIDFactory : NSObject <MKMIDFactory>

@end

NS_ASSUME_NONNULL_END
