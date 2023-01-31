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

#import "MKMFactoryManager.h"

#import "MKMID.h"

id<MKMIDFactory> MKMIDGetFactory(void) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory idFactory];
}

void MKMIDSetFactory(id<MKMIDFactory> factory) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    [man.generalFactory setIDFactory:factory];
}

id<MKMID> MKMIDGenerate(id<MKMMeta> meta, MKMEntityType network,  NSString * _Nullable terminal) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory generateIDWithType:network meta:meta terminal:terminal];
}

id<MKMID> MKMIDCreate(NSString * _Nullable name, id<MKMAddress> address, NSString * _Nullable terminal) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory createID:name address:address terminal:terminal];
}

id<MKMID> MKMIDParse(id identifier) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory parseID:identifier];
}

#pragma mark Broadcast ID

static id<MKMID> s_founder = nil;

static id<MKMID> s_anyone = nil;
static id<MKMID> s_everyone = nil;

id<MKMID> MKMAnyone(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_anyone = [[MKMID alloc] initWithString:@"anyone@anywhere"
                                            name:@"anyone"
                                         address:MKMAnywhere()
                                        terminal:nil];
    });
    return s_anyone;
}

id<MKMID> MKMEveryone(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_everyone = [[MKMID alloc] initWithString:@"everyone@everywhere"
                                              name:@"everyone"
                                           address:MKMEverywhere()
                                          terminal:nil];
    });
    return s_everyone;
}

id<MKMID> MKMFounder(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_founder = [[MKMID alloc] initWithString:@"moky@anywhere"
                                             name:@"moky"
                                          address:MKMAnywhere()
                                         terminal:nil];
    });
    return s_founder;
}

#pragma mark Array

NSArray<id<MKMID>> *MKMIDConvert(NSArray<NSString *> *members) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory convertIDList:members];
}

NSArray<NSString *> *MKMIDRevert(NSArray<id<MKMID>> *members) {
    MKMFactoryManager *man = [MKMFactoryManager sharedManager];
    return [man.generalFactory revertIDList:members];
}

#pragma mark -

//static inline NSString *concat(NSString *name, id<MKMAddress> address, NSString *terminal) {
//    NSUInteger len1 = [name length];
//    NSUInteger len2 = [terminal length];
//    if (len1 > 0) {
//        if (len2 > 0) {
//            return [NSString stringWithFormat:@"%@@%@/%@", name, [address string], terminal];
//        } else {
//            return [NSString stringWithFormat:@"%@@%@", name, [address string]];
//        }
//    } else if (len2 > 0) {
//        return [NSString stringWithFormat:@"%@/%@", [address string], terminal];
//    } else {
//        return [address string];
//    }
//}

//static inline id<MKMID> parse(NSString *string) {
//    NSString *name;
//    id<MKMAddress> address;
//    NSString *terminal;
//    // split ID string
//    NSArray<NSString *> *pair = [string componentsSeparatedByString:@"/"];
//    // terminal
//    if (pair.count == 1) {
//        terminal = nil;
//    } else {
//        assert(pair.count == 2);
//        assert(pair.lastObject.length > 0);
//        terminal = pair.lastObject;
//    }
//    // name @ address
//    pair = [pair.firstObject componentsSeparatedByString:@"@"];
//    assert(pair.firstObject.length > 0);
//    if (pair.count == 1) {
//        // got address without name
//        name = nil;
//        address = MKMAddressParse(pair.firstObject);
//    } else {
//        // got name & address
//        assert(pair.count == 2);
//        assert(pair.lastObject.length > 0);
//        name = pair.firstObject;
//        address = MKMAddressParse(pair.lastObject);
//    }
//    if (address == nil) {
//        return nil;
//    }
//    return [[MKMID alloc] initWithString:string name:name address:address terminal:terminal];
//}

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

- (id)copyWithZone:(nullable NSZone *)zone {
    MKMID *identifier = [super copyWithZone:zone];
    if (identifier) {
        identifier.name = _name;
        identifier.address = _address;
        identifier.terminal = _terminal;
    }
    return identifier;
}

- (MKMEntityType)type {
    return [_address type];
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
