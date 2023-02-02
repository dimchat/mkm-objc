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

#import "MKMFactoryManager.h"

#import "MKMAddress.h"

id<MKMAddressFactory> MKMAddressGetFactory(void) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory addressFactory];
}

void MKMAddressSetFactory(id<MKMAddressFactory> factory) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    [man.generalFactory setAddressFactory:factory];
}

id<MKMAddress> MKMAddressGenerate(MKMEntityType network, id<MKMMeta> meta) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory generateAddressWithType:network meta:meta];
}

id<MKMAddress> MKMAddressCreate(NSString *address) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory createAddress:address];
}

id<MKMAddress> MKMAddressParse(id address) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory parseAddress:address];
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
    //return MKMEntity_IsUser(self.type);
    return _type == MKMEntityType_Any;
}

- (BOOL)isGroup {
    //return MKMEntity_IsGroup(self.type);
    return _type == MKMEntityType_Every;
}

@end

#define BroadcastAddressCreate(S, T) [[BroadcastAddress alloc] initWithString:(S) type:(T)]

static id<MKMAddress> s_anywhere = nil;
static id<MKMAddress> s_everywhere = nil;

id<MKMAddress> MKMAnywhere(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_anywhere = BroadcastAddressCreate(@"anywhere", MKMEntityType_Any);
    });
    return s_anywhere;
}

id<MKMAddress> MKMEverywhere(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_everywhere = BroadcastAddressCreate(@"everywhere", MKMEntityType_Every);
    });
    return s_everywhere;
}
