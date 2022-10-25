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
//  MKMAddress.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMWrapper.h"
#import "MKMMeta.h"

#import "MKMAddress.h"

static id<MKMAddressFactory> s_factory = nil;

id<MKMAddressFactory> MKMAddressGetFactory(void) {
    return s_factory;
}

void MKMAddressSetFactory(id<MKMAddressFactory> factory) {
    s_factory = factory;
}

id<MKMAddress> MKMAddressGenerate(MKMEntityType network, id<MKMMeta> meta) {
    id<MKMAddressFactory> factory = MKMAddressGetFactory();
    return [factory generateAddress:network fromMeta:meta];
}

id<MKMAddress> MKMAddressCreate(NSString *address) {
    id<MKMAddressFactory> factory = MKMAddressGetFactory();
    return [factory createAddress:address];
}

id<MKMAddress> MKMAddressParse(id address) {
    if (!address) {
        return nil;
    } else if ([address conformsToProtocol:@protocol(MKMAddress)]) {
        return (id<MKMAddress>)address;
    } else if ([address conformsToProtocol:@protocol(MKMString)]) {
        address = [(id<MKMString>)address string];
    }
    address = MKMGetString(address);
    id<MKMAddressFactory> factory = MKMAddressGetFactory();
    return [factory parseAddress:address];
}

#pragma mark - Broadcast Address

@interface BroadcastAddress : MKMString <MKMAddress> {
    
    MKMEntityType _type;
}

- (instancetype)initWithString:(NSString *)address type:(MKMEntityType)network
NS_DESIGNATED_INITIALIZER;

@end

@implementation BroadcastAddress

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
    BroadcastAddress *address = [super copyWithZone:zone];
    if (address) {
        address.type = _type;
    }
    return address;
}

- (MKMEntityType)type {
    return _type;
}

- (void)setType:(MKMEntityType)network {
    _type = network;
}

- (BOOL)isBroadcast {
    return YES;
}

- (BOOL)isUser {
    return MKMEntity_IsUser(self.type);
}

- (BOOL)isGroup {
    return MKMEntity_IsGroup(self.type);
}

@end

#define BroadcastAddressCreate(S, T) [[BroadcastAddress alloc] initWithString:(S) type:(T)]

static id<MKMAddress> s_anywhere = nil;
static id<MKMAddress> s_everywhere = nil;

id<MKMAddress> MKMAnywhere(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_anywhere = BroadcastAddressCreate(@"anywhere", MKMEntityType_User);
    });
    return s_anywhere;
}

id<MKMAddress> MKMEverywhere(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_everywhere = BroadcastAddressCreate(@"everywhere", MKMEntityType_Group);
    });
    return s_everywhere;
}

#pragma mark - Base Factory

@interface MKMAddressFactory () {
    
    NSMutableDictionary<NSString *, id<MKMAddress>> *_addresses;
}

@end

@implementation MKMAddressFactory

- (instancetype)init {
    if (self = [super init]) {
        _addresses = [[NSMutableDictionary alloc] init];
        // cache broadcast addresses
        id<MKMAddress> anywhere = MKMAnywhere();
        [_addresses setObject:anywhere forKey:[anywhere string]];
        id<MKMAddress> everywhere = MKMEverywhere();
        [_addresses setObject:everywhere forKey:[everywhere string]];
    }
    return self;
}

- (nullable id<MKMAddress>)generateAddress:(MKMEntityType)network fromMeta:(id<MKMMeta>)meta {
    id<MKMAddress> address = [meta generateAddress:network];
    if (address) {
        [_addresses setObject:address forKey:address.string];
    }
    return address;
}

- (nullable id<MKMAddress>)parseAddress:(NSString *)address {
    id<MKMAddress> addr = [_addresses objectForKey:address];
    if (!addr) {
        addr = [self createAddress:address];
        if (addr) {
            [_addresses setObject:addr forKey:address];
        }
    }
    return addr;
}

- (nullable id<MKMAddress>)createAddress:(NSString *)address {
    NSAssert(false, @"implement me!");
    return nil;
}

@end
