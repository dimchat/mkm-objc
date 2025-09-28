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
//  MKMAddress.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <MingKeMing/MKString.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  @enum MKMEntityType
 *
 *  @abstract A network ID to indicate what kind the entity is.
 *
 *  @discussion An address can identify a person, a group of people,
 *      a team, even a thing.
 *
 *      MKMEntityType_User indicates this entity is a person's account.
 *      An account should have a public key, which proved by meta data.
 *
 *      MKMEntityType_Group indicates this entity is a group of people,
 *      which should have a founder (also the owner), and some members.
 *
 *      MKMEntityType_Station indicates this entity is a DIM network station.
 *
 *      MKMEntityType_ISP indicates this entity is a group for stations.
 *
 *      MKMEntityType_Bot indicates this entity is a bot user.
 *
 *      MKMEntityType_Company indicates a company for stations and/or bots.
 *
 *  Bits:
 *      0000 0001 - group flag
 *      0000 0010 - node flag
 *      0000 0100 - bot flag
 *      0000 1000 - CA flag
 *      ...         (reserved)
 *      0100 0000 - customized flag
 *      1000 0000 - broadcast flag
 *
 *      (All above are just some advices to help choosing numbers :P)
 */
typedef NS_ENUM(UInt8, MKMNetworkID) {
    
    /**
     *  Main: 0, 1
     */
    MKMEntityType_User           = 0x00, // 0000 0000
    MKMEntityType_Group          = 0x01, // 0000 0001 (User Group)
    
    /**
     *  Network: 2, 3
     */
    MKMEntityType_Station        = 0x02, // 0000 0010 (Server Node)
    MKMEntityType_ISP            = 0x03, // 0000 0011 (Service Provider)
    //MKMEntityType_StationGroup = 0x03, // 0000 0011

    /**
     *  Bot: 4, 5
     */
    MKMEntityType_Bot            = 0x04, // 0000 0100 (Business Node)
    MKMEntityType_ICP            = 0x05, // 0000 0101 (Content Provider)
    //MKMEntityType_BotGroup     = 0x05, // 0000 0101

    /**
     *  Management: 6, 7, 8
     */
    MKMEntityType_Supervisor     = 0x06, // 0000 0110 (Company President)
    MKMEntityType_Company        = 0x07, // 0000 0111 (Super Group for ISP/ICP)
    //MKMEntityType_CA           = 0x08, // 0000 1000 (Certification Authority)

    /*
     *  Customized: 64, 65
     */
    //MKMEntityType_AppUser      = 0x40, // 0100 0000 (Application Customized User)
    //MKMEntityType_AppGroup     = 0x41, // 0100 0001 (Application Customized Group)

    /**
     *  Broadcast: 128, 129
     */
    MKMEntityType_Any            = 0x80, // 1000 0000 (anyone@anywhere)
    MKMEntityType_Every          = 0x81, // 1000 0001 (everyone@everywhere)
};
typedef UInt8 MKMEntityType;

#define MKMEntityTypeIsUser(network)      (((network) & MKMEntityType_Group) == MKMEntityType_User)
#define MKMEntityTypeIsGroup(network)     (((network) & MKMEntityType_Group) == MKMEntityType_Group)
#define MKMEntityTypeIsBroadcast(network) (((network) & MKMEntityType_Any) == MKMEntityType_Any)

#pragma mark -

@protocol MKMAddress <MKString>

@property (readonly, nonatomic) MKMEntityType type; // Network ID

- (BOOL)isBroadcast;

- (BOOL)isUser;
- (BOOL)isGroup;

@end

#pragma mark - Address Factory

@protocol MKMMeta;

@protocol MKMAddressFactory <NSObject>

/**
 *  Generate addres with meta & type
 *
 * @param network - address type
 * @param meta - meta info
 * @return Address
 */
- (id<MKMAddress>)generateAddressWithMeta:(id<MKMMeta>)meta
                                     type:(MKMEntityType)network;

/**
 *  Create address from string
 *
 * @param address - address string
 * @return Address
 */
- (nullable id<MKMAddress>)createAddress:(NSString *)address;

/**
 *  Parse string object to address
 *
 * @param address - address string
 * @return Address
 */
- (nullable id<MKMAddress>)parseAddress:(NSString *)address;

@end

#ifdef __cplusplus
extern "C" {
#endif

_Nullable id<MKMAddressFactory> MKMAddressGetFactory(void);
void MKMAddressSetFactory(id<MKMAddressFactory> factory);

id<MKMAddress> MKMAddressGenerate(MKMEntityType network, id<MKMMeta> meta);

_Nullable id<MKMAddress> MKMAddressCreate(NSString *address);

_Nullable id<MKMAddress> MKMAddressParse(_Nullable id address);

// Broadcast Addresses
id<MKMAddress> MKMAnywhere(void);
id<MKMAddress> MKMEverywhere(void);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
