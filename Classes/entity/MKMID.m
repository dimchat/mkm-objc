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

@interface MKMID ()

@property (strong, nonatomic, nullable) NSString *name;
@property (strong, nonatomic) id<MKMAddress> address;
@property (strong, nonatomic, nullable) NSString *terminal;

@end

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

- (BOOL)isEqual:(id)object {
    if ([super isEqual:object]) {
        return YES;
    }
    if ([object conformsToProtocol:@protocol(MKMID)]) {
        id<MKMID> other = (id<MKMID>)object;
        // check address
        if ([_address isEqual:other.address]) {
            // check name
            if (_name.length == 0) {
                return other.name.length == 0;
            } else {
                return [_name isEqualToString:other.name];
            }
        } else {
            return NO;
        }
    }
    NSString *other;
    if ([object conformsToProtocol:@protocol(MKMString)]) {
        other = [(id<MKMString>)object string];
    } else if ([object isKindOfClass:[NSString class]]) {
        other = (NSString *)object;
    } else {
        NSAssert(!object, @"ID error: %@", object);
        return NO;
    }
    // comparing without terminal
    NSArray<NSString *> *pair = [other componentsSeparatedByString:@"/"];
    other = pair.firstObject;
    if (_terminal.length == 0) {
        return [other isEqualToString:self.string];
    } else {
        pair = [self.string componentsSeparatedByString:@"/"];
        return [other isEqualToString:pair.firstObject];
    }
}

- (MKMNetworkType)type {
    return _address.network;
}

+ (BOOL)isUser:(id<MKMID>)identifier {
    return MKMAddressIsUser(identifier.address);
}

+ (BOOL)isGroup:(id<MKMID>)identifier {
    return MKMAddressIsGroup(identifier.address);
}

+ (BOOL)isBroadcast:(id<MKMID>)identifier {
    return MKMAddressIsBroadcast(identifier.address);
}

static MKMID *s_anyone = nil;
static MKMID *s_everyone = nil;

+ (MKMID *)anyone {
    @synchronized (self) {
        if (s_anyone == nil) {
            s_anyone = [[MKMID alloc] initWithName:@"anyone" address:MKMAnywhere()];
        }
    }
    return s_anyone;
}

+ (MKMID *)everyone {
    @synchronized (self) {
        if (s_everyone == nil) {
            s_everyone = [[MKMID alloc] initWithName:@"everyone" address:MKMEverywhere()];
        }
    }
    return s_everyone;
}

@end

@implementation MKMID (IDType)

- (BOOL)isBroadcast {
    return MKMAddressIsBroadcast(_address);
}

- (BOOL)isUser {
    return MKMAddressIsUser(_address);
}

- (BOOL)isGroup {
    return MKMAddressIsGroup(_address);
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
    return [[MKMID alloc] initWithString:concat(name, address, terminal)
                                    name:name
                                 address:address
                                terminal:terminal];
}

- (nullable __kindof id<MKMID>)createID:(NSString *)identifier {
    NSString *name;
    id<MKMAddress> address;
    NSString *terminal;
    // split ID string
    NSArray<NSString *> *pair = [identifier componentsSeparatedByString:@"/"];
    // terminal
    if (pair.count == 1) {
        terminal = nil;
    } else {
        NSAssert(pair.count == 2, @"ID error: %@", identifier);
        NSAssert(pair.lastObject.length > 0, @"ID.terminal error: %@", identifier);
        terminal = pair.lastObject;
    }
    // name @ address
    pair = [pair.firstObject componentsSeparatedByString:@"@"];
    NSAssert(pair.firstObject.length > 0, @"ID error: %@", identifier);
    if (pair.count == 1) {
        // got address without name
        name = nil;
        address = MKMAddressFromString(pair.firstObject);
    } else {
        // got name & address
        NSAssert(pair.count == 2, @"ID error: %@", identifier);
        NSAssert(pair.lastObject.length > 0, @"ID.address error: %@", identifier);
        name = pair.firstObject;
        address = MKMAddressFromString(pair.lastObject);
    }
    if (address == nil) {
        return nil;
    }
    return [[MKMID alloc] initWithString:identifier
                                    name:name
                                 address:address
                                terminal:terminal];
}

- (nullable id<MKMID>)parseID:(NSString *)identifier {
    MKMID *anyone = MKMAnyone();
    if ([anyone isEqual:identifier]) {
        return anyone;
    }
    MKMID *everyone = MKMEveryone();
    if ([everyone isEqual:identifier]) {
        return everyone;
    }
    id<MKMID> ID = [_identifiers objectForKey:identifier];
    if (!ID) {
        ID = [self createID:identifier];
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
