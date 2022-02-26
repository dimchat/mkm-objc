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

#import "MKMAddress.h"
#import "MKMMeta.h"

static id<MKMAddressFactory> s_factory = nil;

id<MKMAddressFactory> MKMAddressGetFactory(void) {
    return s_factory;
}

void MKMAddressSetFactory(id<MKMAddressFactory> factory) {
    s_factory = factory;
}

id<MKMAddress> MKMAddressGenerate(UInt8 network, id<MKMMeta> meta) {
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
    id<MKMAddressFactory> factory = MKMAddressGetFactory();
    return [factory parseAddress:address];
}

#pragma mark - Base Address

@interface MKMAddress () {
    
    UInt8 _network;
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
    return [self initWithString:string network:0];
}

- (instancetype)initWithString:(NSString *)address {
    //NSAssert(false, @"DON'T call me!");
    return [self initWithString:address network:0];
}

/* designated initializer */
- (instancetype)initWithString:(NSString *)address network:(UInt8)type {
    if (self = [super initWithString:address]) {
        _network = type;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    MKMAddress *address = [super copyWithZone:zone];
    if (address) {
        address.network = _network;
    }
    return address;
}

- (UInt8)network {
    return _network;
}

- (void)setNetwork:(UInt8)network {
    _network = network;
}

- (BOOL)isBroadcast {
    //NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)isUser {
    return MKMNetwork_IsUser(self.network);
}

- (BOOL)isGroup {
    return MKMNetwork_IsGroup(self.network);
}

@end

#pragma mark - Broadcast

@interface BroadcastAddress : MKMAddress

+ (instancetype)create:(NSString *)string network:(MKMNetworkType)type;

@end

@implementation BroadcastAddress

- (BOOL)isBroadcast {
    return YES;
}

+ (instancetype)create:(NSString *)string network:(MKMNetworkType)type {
    return [[self alloc] initWithString:string network:type];
}

@end

static id<MKMAddress> s_anywhere = nil;
static id<MKMAddress> s_everywhere = nil;

id<MKMAddress> MKMAnywhere(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_anywhere = [BroadcastAddress create:@"anywhere" network:MKMNetwork_Main];
    });
    return s_anywhere;
}

id<MKMAddress> MKMEverywhere(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_everywhere = [BroadcastAddress create:@"everywhere" network:MKMNetwork_Group];
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

- (nullable __kindof id<MKMAddress>)generateAddress:(UInt8)network fromMeta:(id<MKMMeta>)meta {
    id<MKMAddress> address = [meta generateAddress:network];
    if (address) {
        [_addresses setObject:address forKey:address.string];
    }
    return address;
}

- (nullable __kindof id<MKMAddress>)parseAddress:(NSString *)address {
    id<MKMAddress> addr = [_addresses objectForKey:address];
    if (!addr) {
        addr = [self createAddress:address];
        if (addr) {
            [_addresses setObject:addr forKey:address];
        }
    }
    return addr;
}

- (nullable __kindof id<MKMAddress>)createAddress:(NSString *)address {
    NSAssert(false, @"implement me!");
    return nil;
}

@end
