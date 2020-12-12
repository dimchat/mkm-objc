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

@interface BroadcastAddress : MKMAddress
@end

@implementation BroadcastAddress
@end

@interface MKMAddress ()

@property (nonatomic) MKMNetworkType network;

@end

@implementation MKMAddress

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    NSString *string = nil;
    return [self initWithString:string network:0];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSAssert(false, @"DON'T call me!");
    NSString *string = nil;
    return [self initWithString:string network:0];
}

- (instancetype)initWithString:(NSString *)aString {
    NSAssert(false, @"DON'T call me!");
    NSString *string = nil;
    return [self initWithString:string network:0];
}

/* designated initializer */
- (instancetype)initWithString:(NSString *)address network:(MKMNetworkType)type {
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

+ (BOOL)isUser:(id<MKMAddress>)address {
    return MKMNetwork_IsUser([address network]);
}

+ (BOOL)isGroup:(id<MKMAddress>)address {
    return MKMNetwork_IsGroup([address network]);
}

+ (BOOL)isBroadcast:(id<MKMAddress>)address {
    return [address isKindOfClass:[BroadcastAddress class]];
}

static MKMAddress *s_anywhere = nil;
static MKMAddress *s_everywhere = nil;

+ (MKMAddress *)anywhere {
    @synchronized (self) {
        if (s_anywhere == nil) {
            s_anywhere = [[BroadcastAddress alloc] initWithString:@"anywhere"
                                                          network:MKMNetwork_Main];
        }
    }
    return s_anywhere;
}

+ (MKMAddress *)everywhere {
    @synchronized (self) {
        if (s_everywhere == nil) {
            s_everywhere = [[BroadcastAddress alloc] initWithString:@"everywhere"
                                                            network:MKMNetwork_Group];
        }
    }
    return s_everywhere;
}

@end

#pragma mark - Creation

@interface MKMAddressFactory () {
    
    NSMutableDictionary<NSString *, id<MKMAddress>> *_addresses;
}

@end

@implementation MKMAddressFactory

- (instancetype)init {
    if (self = [super init]) {
        _addresses = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (nullable __kindof id<MKMAddress>)parseAddress:(NSString *)address {
    MKMAddress *anywhere = MKMAnywhere();
    if ([anywhere isEqual:address]) {
        return anywhere;
    }
    MKMAddress *everywhere = MKMEverywhere();
    if ([everywhere isEqual:address]) {
        return everywhere;
    }
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

@implementation MKMAddress (Creation)

static id<MKMAddressFactory> s_factory = nil;

+ (void)setFactory:(id<MKMAddressFactory>)factory {
    s_factory = factory;
}

+ (nullable __kindof id<MKMAddress>)parse:(NSString *)address {
    if (address.length == 0) {
        return nil;
    } else if ([address conformsToProtocol:@protocol(MKMAddress)]) {
        return (id<MKMAddress>)address;
    } else if ([address isKindOfClass:[MKMString class]]) {
        MKMString *str = (MKMString *)address;
        return [s_factory parseAddress:[str string]];
    } else {
        return [s_factory parseAddress:address];
    }
}

@end
