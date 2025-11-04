// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2025 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2025 Albert Moky
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
//  MKMBroadcast.m
//  MingKeMing
//
//  Created by Albert Moky on 2025/10/7.
//  Copyright © 2025 DIM Group. All rights reserved.
//

#import "MKMBroadcast.h"

id<MKMAddress> MKMAnywhere   = nil;
id<MKMAddress> MKMEverywhere = nil;

id<MKMID> MKMAnyone   = nil;
id<MKMID> MKMEveryone = nil;
id<MKMID> MKMFounder  = nil;

#define BroadcastAddressCreate(S, T)                                           \
                [[MKMAddress alloc] initWithString:(S) type:(T)]               \
                                        /* EOF 'BroadcastAddressCreate(S, T)' */

#define BroadcastIDCreate(N, A)                                                \
                [[MKMID alloc] initWithString:MKMIDConcat(N, A, nil)           \
                                         name:(N)                              \
                                      address:(A)                              \
                                     terminal:nil]                             \
                                             /* EOF 'BroadcastIDCreate(N, A)' */

void MKMInitializeBroadcastAddresses(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        MKMAnywhere   = BroadcastAddressCreate(@"anywhere",   MKMEntityType_Any);
        MKMEverywhere = BroadcastAddressCreate(@"everywhere", MKMEntityType_Every);

    });
}

void MKMInitializeBroadcastIdentifiers(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        MKMAnyone   = BroadcastIDCreate(@"anyone",   MKMAnywhere);
        MKMEveryone = BroadcastIDCreate(@"everyone", MKMEverywhere);
        MKMFounder  = BroadcastIDCreate(@"moky",     MKMAnywhere);

    });
}

__attribute__((constructor))
static void autoInitializeBroadcasts(void) {
    MKMInitializeBroadcastAddresses();
    MKMInitializeBroadcastIdentifiers();
}

#pragma mark - Base Address

@interface MKMAddress () {
    
    MKMEntityType _type;
}

@end

@implementation MKMAddress

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    NSString *string = nil;
    return [self initWithString:string];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSAssert(false, @"DON'T call me!");
    NSString *string = nil;
    return [self initWithString:string type:0];
}

- (instancetype)initWithString:(NSString *)address {
    //NSAssert(false, @"DON'T call me!");
    return [self initWithString:address type:0];
}

/* designated initializer */
- (instancetype)initWithString:(NSString *)address type:(MKMEntityType)network {
    if (self = [super initWithString:address]) {
        _type = network;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    MKMAddress *address = [super copyWithZone:zone];
    if (address) {
        address.network = _type;
    }
    return address;
}

// Override
- (MKMEntityType)network {
    return _type;
}

- (void)setNetwork:(MKMEntityType)network {
    _type = network;
}

@end

#pragma mark - Base ID

@interface MKMID ()

@property (strong, nonatomic, nullable) NSString *name;
@property (strong, nonatomic) id<MKMAddress> address;
@property (strong, nonatomic, nullable) NSString *terminal;

@end

@implementation MKMID

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    NSString *string = nil;
    id<MKMAddress> address = nil;
    return [self initWithString:string name:nil address:address terminal:nil];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSAssert(false, @"DON'T call me!");
    NSString *string = nil;
    id<MKMAddress> address = nil;
    return [self initWithString:string name:nil address:address terminal:nil];
}

- (instancetype)initWithString:(NSString *)aString {
    //NSAssert(false, @"DON'T call me!");
    id<MKMAddress> address = nil;
    return [self initWithString:aString name:nil address:address terminal:nil];
}

/* designated initializer */
- (instancetype)initWithString:(NSString *)string
                          name:(nullable NSString *)seed
                       address:(id<MKMAddress>)address
                      terminal:(nullable NSString *)location {
    if (self = [super initWithString:string]) {
        self.name = seed;
        self.address = address;
        self.terminal = location;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    MKMID *identifier = [super copyWithZone:zone];
    if (identifier) {
        identifier.name = _name;
        identifier.address = _address;
        identifier.terminal = _terminal;
    }
    return identifier;
}

// Override
- (MKMEntityType)type {
    return [_address network];
}

// Override
- (BOOL)isBroadcast {
    return MKMEntityTypeIsBroadcast(self.type);
}

// Override
- (BOOL)isUser {
    return MKMEntityTypeIsUser(self.type);
}

// Override
- (BOOL)isGroup {
    return MKMEntityTypeIsGroup(self.type);
}

@end

NSString *MKMIDConcat(NSString * _Nullable name,
                      id<MKMAddress> address,
                      NSString *_Nullable terminal) {
    NSUInteger len1 = [name length];
    NSUInteger len2 = [terminal length];
    NSString *addr = [address string];
    if (len1 == 0) {
        if (len2 == 0) {
            // address only
            return addr;
        }
        // address + terminal
        return [NSString stringWithFormat:@"%@/%@", addr, terminal];
    } else if (len2 == 0) {
        // name + address
        return [NSString stringWithFormat:@"%@@%@", name, addr];
    }
    // name + address + terminal
    return [NSString stringWithFormat:@"%@@%@/%@", name, addr, terminal];
}
