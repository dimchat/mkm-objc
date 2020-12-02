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

@interface MKMAddress () {
    
    MKMNetworkType _type;
}

@end

@implementation MKMAddress

- (instancetype)initWithString:(NSString *)address network:(MKMNetworkType)type {
    if (self = [super initWithString:address]) {
        _network = type;
    }
    return self;
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

@implementation MKMAddress (Creation)

static id<MKMAddressFactory> s_factory = nil;

+ (void)setFactory:(id<MKMAddressFactory>)factory {
    s_factory = factory;
}

+ (nullable id<MKMAddress>)parse:(NSString *)address {
    if (address.length == 0) {
        return nil;
    } else if ([address conformsToProtocol:@protocol(MKMAddress)]) {
        return (id<MKMAddress>)address;
    }
    return [s_factory parseAddress:address];
}

@end
