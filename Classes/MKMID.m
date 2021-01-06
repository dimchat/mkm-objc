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
@property (strong, nonatomic) __kindof id<MKMAddress> address;
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

- (NSUInteger)hash {
    return [self.address hash];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if ([object conformsToProtocol:@protocol(MKMID)]) {
        // compare with name & address
        return [MKMID identifier:self isEqual:object];
    }
    NSString *str;
    if ([object conformsToProtocol:@protocol(MKMString)]) {
        str = [object string];
    } else if ([object isKindOfClass:[NSString class]]) {
        str = object;
    } else {
        NSAssert(!object, @"ID error: %@", object);
        return NO;
    }
    // comparing without terminal
    NSArray<NSString *> *pair = [object componentsSeparatedByString:@"/"];
    NSAssert(pair.firstObject.length > 0, @"ID error: %@", object);
    if (_terminal.length == 0) {
        return [pair.firstObject isEqualToString:self.string];
    } else {
        pair = [self.string componentsSeparatedByString:@"/"];
        return [pair.firstObject isEqualToString:pair.firstObject];
    }
}

- (MKMNetworkType)type {
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

+ (BOOL)identifier:(id<MKMID>)ID1 isEqual:(id<MKMID>)ID2 {
    // check ID.address
    if ([ID1.address isEqual:ID2.address]) {
        // check ID.name
        if (ID1.name.length == 0) {
            return ID2.name.length == 0;
        } else {
            return [ID1.name isEqualToString:ID2.name];
        }
    }
    return NO;
}

@end

@implementation MKMID (Broadcast)

static MKMID *s_anyone = nil;
static MKMID *s_everyone = nil;

+ (MKMID *)anyone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_anyone = [[MKMID alloc] initWithName:@"anyone" address:MKMAnywhere()];
    });
    return s_anyone;
}

+ (MKMID *)everyone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_everyone = [[MKMID alloc] initWithName:@"everyone" address:MKMEverywhere()];
    });
    return s_everyone;
}

@end

@implementation MKMID (Array)

+ (NSMutableArray<id<MKMID>> *)convert:(NSArray<NSString *> *)members {
    NSMutableArray<id<MKMID>> *array = [[NSMutableArray alloc] initWithCapacity:members.count];
    id<MKMID> ID;
    for (NSString *item in members) {
        ID = [self parse:item];
        if (ID) {
            [array addObject:ID];
        }
    }
    return array;
}

+ (NSMutableArray<NSString *> *)revert:(NSArray<id<MKMID>> *)members {
    NSMutableArray<NSString *> *array = [[NSMutableArray alloc] initWithCapacity:members.count];
    for (id<MKMID> item in members) {
        [array addObject:[item string]];
    }
    return array;
}

@end

#pragma mark - Creation

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

- (id<MKMID>)createID:(nullable NSString *)name
              address:(id<MKMAddress>)address
             terminal:(nullable NSString *)terminal {
    NSString *string = concat(name, address, terminal);
    id<MKMID> ID = [_identifiers objectForKey:string];
    if (!ID) {
        ID = [[MKMID alloc] initWithString:string name:name address:address terminal:terminal];
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

@implementation MKMID (Creation)

static id<MKMIDFactory> s_factory = nil;

+ (id<MKMIDFactory>)factory {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (s_factory == nil) {
            s_factory = [[MKMIDFactory alloc] init];
        }
    });
    return s_factory;
}

+ (void)setFactory:(id<MKMIDFactory>)factory {
    s_factory = factory;
}

+ (id<MKMID>)create:(nullable NSString *)name
            address:(id<MKMAddress>)address
           terminal:(nullable NSString *)terminal {
    return [[self factory] createID:name address:address terminal:terminal];
}

+ (nullable id<MKMID>)parse:(NSString *)identifier {
    if (identifier.length == 0) {
        return nil;
    } else if ([identifier conformsToProtocol:@protocol(MKMID)]) {
        return (id<MKMID>)identifier;
    } else if ([identifier isKindOfClass:[MKMString class]]) {
        MKMString *str = (MKMString *)identifier;
        return [[self factory] parseID:[str string]];
    } else {
        return [[self factory] parseID:identifier];
    }
}

@end
