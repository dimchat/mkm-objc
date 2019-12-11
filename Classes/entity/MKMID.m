// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
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

#import "NSObject+Compare.h"

#import "MKMID.h"

@interface MKMID () {
    
    NSString *_name;
    MKMAddress *_address;
    NSString *_terminal;
}

@end

@implementation MKMID

- (instancetype)initWithString:(NSString *)aString {
    if (self = [super initWithString:aString]) {
        // Parse string for ID
        NSArray *pair;
        
        // get terminal
        pair = [aString componentsSeparatedByString:@"/"];
        if (pair.count > 1) {
            assert(pair.count == 2);
            aString = pair.firstObject; // drop the tail
            _terminal = pair.lastObject;
            assert(_terminal.length > 0);
        } else {
            _terminal = nil;
        }
        
        // get name & address
        pair = [aString componentsSeparatedByString:@"@"];
        if (pair.count > 1) {
            assert(pair.count == 2);
            _name = pair.firstObject;
            assert(_name.length > 0);
            _address = MKMAddressFromString(pair.lastObject);
        } else {
            _name = nil;
            _address = MKMAddressFromString(pair.firstObject);
        }
    }
    return self;
}

- (instancetype)initWithName:(nullable NSString *)seed
                     address:(MKMAddress *)addr {
    NSAssert(addr, @"ID address invalid: %@", addr);
    
    NSString *str = [NSString stringWithFormat:@"%@@%@", seed, addr];
    if (self = [super initWithString:str]) {
        _name = seed;
        _address = addr;
        _terminal = nil;
    }
    return self;
}

- (instancetype)initWithAddress:(MKMAddress *)addr {
    NSAssert(addr, @"ID address invalid: %@", addr);
    return [self initWithName:nil address:addr];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[NSString class]]) {
        // object empty
        return NO;
    }
    if ([super isEqual:object]) {
        // same object
        return YES;
    }
    if ([object isKindOfClass:[MKMID class]]) {
        MKMID *ID = (MKMID *)object;
        // check address
        if (![_address isEqual:ID.address]) {
            return NO;
        }
        // check name
        if ([_name length] == 0) {
            return [ID.name length] == 0;
        } else {
            return [_name isEqual:ID.name];
        }
    }
    NSAssert([object isKindOfClass:[NSString class]], @"ID error: %@", object);
    // comparing without terminal
    NSArray *pair = [object componentsSeparatedByString:@"/"];
    NSString *str1 = pair.firstObject;
    if (_terminal.length == 0) {
        return [_storeString isEqualToString:str1];
    } else {
        pair = [_storeString componentsSeparatedByString:@"/"];
        return [pair.firstObject isEqualToString:str1];
    }
}

- (void)setTerminal:(NSString *)terminal {
    if (NSStringNotEquals(_terminal, terminal)) {
        // 1. remove '/' from terminal
        NSArray *pair = [terminal componentsSeparatedByString:@"/"];
        NSAssert(pair.count == 1, @"terminal error: %@", terminal);
        terminal = pair.lastObject;
        
        // 2. remove '/xxx' from ID
        pair = [_storeString componentsSeparatedByString:@"/"];
        NSAssert(pair.count <= 2, @"ID error: %@", _storeString);
        NSString *string = pair.firstObject;
        
        // 3. update store string
        if (terminal.length > 0) {
            _storeString = [string stringByAppendingFormat:@"/%@", terminal];
        } else {
            _storeString = string;
        }
        
        // 4. update terminal
        _terminal = terminal;
    }
}

- (BOOL)isValid {
    return _address != nil;
}

- (MKMNetworkType)type {
    return _address.network;
}

- (UInt32)number {
    return _address.code;
}

@end

@implementation MKMID (Broadcast)

- (BOOL)isBroadcast {
    return [self.address isBroadcast];
}

@end

@implementation MKMID (Runtime)

+ (nullable instancetype)getInstance:(id)ID {
    if (!ID) {
        return nil;
    }
    if ([ID isKindOfClass:[MKMID class]]) {
        // return ID object directly
        return ID;
    }
    NSAssert([ID isKindOfClass:[NSString class]], @"ID should be a string: %@", ID);
    return [[self alloc] initWithString:ID];
}

@end
