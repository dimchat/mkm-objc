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
//  MKMID.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMMeta.h"

static id<MKMIDFactory> s_factory = nil;

id<MKMIDFactory> MKMIDGetFactory(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (s_factory == nil) {
            s_factory = [[MKMIDFactory alloc] init];
        }
    });
    return s_factory;
}

void MKMIDSetFactory(id<MKMIDFactory> factory) {
    s_factory = factory;
}

id<MKMID> MKMIDGenerate(id<MKMMeta> meta, UInt8 network,  NSString * _Nullable terminal) {
    id<MKMIDFactory> factory = MKMIDGetFactory();
    return [factory generateID:meta network:network terminal:terminal];
}

id<MKMID> MKMIDCreate(NSString * _Nullable name, id<MKMAddress> address, NSString * _Nullable terminal) {
    id<MKMIDFactory> factory = MKMIDGetFactory();
    return [factory createID:name address:address terminal:terminal];
}

id<MKMID> MKMIDParse(id identifier) {
    if (!identifier) {
        return nil;
    } else if ([identifier conformsToProtocol:@protocol(MKMID)]) {
        return (id<MKMID>)identifier;
    } else if ([identifier isKindOfClass:[MKMString class]]) {
        identifier = [identifier string];
    }
    id<MKMIDFactory> factory = MKMIDGetFactory();
    return [factory parseID:identifier];
}

#pragma mark Broadcast ID

static id<MKMID> s_founder = nil;

static id<MKMID> s_anyone = nil;
static id<MKMID> s_everyone = nil;

id<MKMID> MKMAnyone(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_anyone = MKMIDCreate(@"anyone", MKMAnywhere(), nil);
    });
    return s_anyone;
}

id<MKMID> MKMEveryone(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_everyone = MKMIDCreate(@"everyone", MKMEverywhere(), nil);
    });
    return s_everyone;
}

id<MKMID> MKMFounder(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_anyone = MKMIDCreate(@"moky", MKMAnywhere(), nil);
    });
    return s_anyone;
}

#pragma mark Array

NSArray<id<MKMID>> *MKMIDConvert(NSArray<NSString *> *members) {
    NSMutableArray<id<MKMID>> *array = [[NSMutableArray alloc] initWithCapacity:members.count];
    id<MKMID> ID;
    for (NSString *item in members) {
        ID = MKMIDFromString(item);
        if (ID) {
            [array addObject:ID];
        }
    }
    return array;
}

NSArray<NSString *> *MKMIDRevert(NSArray<id<MKMID>> *members) {
    NSMutableArray<NSString *> *array = [[NSMutableArray alloc] initWithCapacity:members.count];
    NSString *str;
    for (id<MKMID> item in members) {
        str = [item string];
        if (str) {
            [array addObject:str];
        }
    }
    return array;
}

#pragma mark -

static inline NSString *concat(NSString *name, id<MKMAddress> address, NSString *terminal) {
    NSUInteger len1 = [name length];
    NSUInteger len2 = [terminal length];
    if (len1 > 0) {
        if (len2 > 0) {
            return [NSString stringWithFormat:@"%@@%@/%@", name, [address string], terminal];
        } else {
            return [NSString stringWithFormat:@"%@@%@", name, [address string]];
        }
    } else if (len2 > 0) {
        return [NSString stringWithFormat:@"%@/%@", [address string], terminal];
    } else {
        return [address string];
    }
}

static inline id<MKMID> parse(NSString *string) {
    NSString *name;
    id<MKMAddress> address;
    NSString *terminal;
    // split ID string
    NSArray<NSString *> *pair = [string componentsSeparatedByString:@"/"];
    // terminal
    if (pair.count == 1) {
        terminal = nil;
    } else {
        assert(pair.count == 2);
        assert(pair.lastObject.length > 0);
        terminal = pair.lastObject;
    }
    // name @ address
    pair = [pair.firstObject componentsSeparatedByString:@"@"];
    assert(pair.firstObject.length > 0);
    if (pair.count == 1) {
        // got address without name
        name = nil;
        address = MKMAddressFromString(pair.firstObject);
    } else {
        // got name & address
        assert(pair.count == 2);
        assert(pair.lastObject.length > 0);
        name = pair.firstObject;
        address = MKMAddressFromString(pair.lastObject);
    }
    if (address == nil) {
        return nil;
    }
    return [[MKMID alloc] initWithString:string name:name address:address terminal:terminal];
}

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
        _name = seed;
        _address = address;
        _terminal = location;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)seed
                     address:(id<MKMAddress>)address
                    terminal:(NSString *)location {
    return [self initWithString:concat(seed, address, location)
                           name:seed
                        address:address
                       terminal:location];
}

- (instancetype)initWithName:(NSString *)seed
                     address:(id<MKMAddress>)address {
    return [self initWithString:concat(seed, address, nil)
                           name:seed
                        address:address
                       terminal:nil];
}

- (instancetype)initWithAddress:(id<MKMAddress>)address {
    return [self initWithString:concat(nil, address, nil)
                           name:nil
                        address:address
                       terminal:nil];
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

- (UInt8)type {
    return _address.network;
}

- (BOOL)isBroadcast {
    return [_address isBroadcast];
}

- (BOOL)isUser {
    return [_address isUser];
}

- (BOOL)isGroup {
    return [_address isGroup];
}

@end

#pragma mark - ID Factory

@interface MKMIDFactory () {
    
    NSMutableDictionary<NSString *, id<MKMID>> *_identifiers;
}

@end

@implementation MKMIDFactory

- (instancetype)init {
    if (self = [super init]) {
        _identifiers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id<MKMID>)generateID:(id<MKMMeta>)meta network:(UInt8)type terminal:(nullable NSString *)loc {
    id<MKMAddress> address = MKMAddressGenerate(type, meta);
    NSAssert(address, @"failed to generate ID with meta: %@", meta);
    return MKMIDCreate(meta.seed, address, loc);
}

- (id<MKMID>)createID:(nullable NSString *)name address:(id<MKMAddress>)address terminal:(nullable NSString *)loc {
    NSString *string = concat(name, address, loc);
    id<MKMID> ID = [_identifiers objectForKey:string];
    if (!ID) {
        ID = [[MKMID alloc] initWithString:string name:name address:address terminal:loc];
        [_identifiers setObject:ID forKey:string];
    }
    return ID;
}

- (nullable id<MKMID>)parseID:(NSString *)identifier {
    id<MKMID> ID = [_identifiers objectForKey:identifier];
    if (!ID) {
        ID = parse(identifier);
        if (ID) {
            [_identifiers setObject:ID forKey:identifier];
        }
    }
    return ID;
}

@end
