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

- (instancetype)initWithString:(NSString *)string {
    if (self = [super initWithString:string]) {
        // lazy
        _name = nil;
        _address = nil;
        _terminal = nil;
    }
    return self;
}

- (instancetype)initWithName:(nullable NSString *)seed
                     address:(MKMAddress *)addr
                    terminal:(nullable NSString *)location {
    NSAssert(addr, @"ID address invalid: %@", addr);
    NSString *str;
    if (seed.length > 0 && location.length > 0) {
        str = [NSString stringWithFormat:@"%@@%@/%@", seed, addr, location];
    } else if (seed.length > 0) {
        str = [NSString stringWithFormat:@"%@@%@", seed, addr];
    } else if (location.length > 0) {
        str = [NSString stringWithFormat:@"%@/%@", addr, location];
    } else {
        str = [NSString stringWithFormat:@"%@", addr];
    }
    if (self = [super initWithString:str]) {
        _name = seed;
        _address = addr;
        _terminal = location;
    }
    return self;
}

- (instancetype)initWithName:(nullable NSString *)seed
                     address:(MKMAddress *)addr {
    return [self initWithName:seed address:addr terminal:nil];
}

- (instancetype)initWithAddress:(MKMAddress *)addr {
    return [self initWithName:nil address:addr terminal:nil];
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
        if (![self.address isEqual:ID.address]) {
            return NO;
        }
        // check name
        NSString *name = self.name;
        if ([name length] == 0) {
            return [ID.name length] == 0;
        } else {
            return [name isEqualToString:ID.name];
        }
    }
    NSAssert([object isKindOfClass:[NSString class]], @"ID error: %@", object);
    // comparing without terminal
    NSArray *pair = [object componentsSeparatedByString:@"/"];
    NSString *str1 = pair.firstObject;
    NSAssert(str1.length > 0, @"ID error: %@", object);
    if ([self.terminal length] == 0) {
        return [str1 isEqualToString:_storeString];
    } else {
        pair = [_storeString componentsSeparatedByString:@"/"];
        return [str1 isEqualToString:pair.firstObject];
    }
}

- (nullable NSString *)name {
    if (![self isValid]) {
        return nil;
    }
    return _name;
}

- (MKMAddress *)address {
    if (!_address) {
        // split ID string
        NSArray<NSString *> *pair;
        // get terminal
        pair = [_storeString componentsSeparatedByString:@"/"];
        if (pair.count > 1) {
            assert(pair.count == 2);
            assert(pair.lastObject.length > 0);
            _terminal = pair.lastObject;
        } else {
            _terminal = nil;
        }
        // get name & address
        assert(pair.firstObject.length > 0);
        pair = [pair.firstObject componentsSeparatedByString:@"@"];
        assert(pair.firstObject.length > 0);
        if (pair.count > 1) {
            assert(pair.count == 2);
            assert(pair.lastObject.length > 0);
            _name = pair.firstObject;
            _address = MKMAddressFromString(pair.lastObject);
        } else {
            _name = nil;
            _address = MKMAddressFromString(pair.firstObject);
        }
    }
    return _address;
}

- (nullable NSString *)terminal {
    if (![self isValid]) {
        return nil;
    }
    return _terminal;
}

//- (void)setTerminal:(NSString *)terminal {
//    if (NSStringNotEquals(_terminal, terminal)) {
//        // 1. remove '/' from terminal
//        NSArray *pair = [terminal componentsSeparatedByString:@"/"];
//        NSAssert(pair.count == 1, @"terminal error: %@", terminal);
//        terminal = pair.lastObject;
//
//        // 2. remove '/xxx' from ID
//        pair = [_storeString componentsSeparatedByString:@"/"];
//        NSAssert(pair.count <= 2, @"ID error: %@", _storeString);
//        NSString *string = pair.firstObject;
//
//        // 3. update store string
//        if (terminal.length > 0) {
//            _storeString = [string stringByAppendingFormat:@"/%@", terminal];
//        } else {
//            _storeString = string;
//        }
//
//        // 4. update terminal
//        _terminal = terminal;
//    }
//}

- (BOOL)isValid {
    return self.number > 0;
}

- (MKMNetworkType)type {
    return self.address.network;
}

- (UInt32)number {
    return self.address.code;
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
