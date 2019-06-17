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
    const MKMAddress *_address;
    NSString *_terminal;
}

@end

@implementation MKMID

+ (instancetype)IDWithID:(id)ID {
    if ([ID isKindOfClass:[MKMID class]]) {
        return ID;
    } else if ([ID isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithString:ID];
    } else {
        NSAssert(!ID, @"unexpected ID: %@", ID);
        return nil;
    }
}

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
            _address = [[MKMAddress alloc] initWithString:pair.lastObject];
        } else {
            _name = nil;
            _address = [[MKMAddress alloc] initWithString:pair.firstObject];
        }
    }
    return self;
}

- (instancetype)initWithName:(nullable const NSString *)seed
                     address:(const MKMAddress *)addr {
    NSAssert(addr, @"ID address invalid: %@", addr);
    
    NSString *str = [NSString stringWithFormat:@"%@@%@", seed, addr];
    if (self = [super initWithString:str]) {
        _name = [seed copy];
        _address = addr;
        _terminal = nil;
    }
    return self;
}

- (instancetype)initWithAddress:(const MKMAddress *)addr {
    NSAssert(addr, @"ID address invalid: %@", addr);
    return [self initWithName:nil address:addr];
}

- (BOOL)isEqual:(id)object {
    MKMID *ID = [MKMID IDWithID:object];
    // check name
    if (NSStringNotEquals(_name, ID.name)) {
        return NO;
    }
    // compare address
    return [_address isEqual:ID.address];
}

- (void)setTerminal:(NSString *)terminal {
    if (NSStringNotEquals(_terminal, terminal)) {
        _terminal = terminal;
        
        // update store string
        NSArray *pair = [_storeString componentsSeparatedByString:@"/"];
        NSAssert(pair.count == 1 || pair.count == 2, @"ID error: %@", _storeString);
        if (terminal.length > 0) {
            NSAssert([terminal rangeOfString:@"/"].location == NSNotFound, @"terminal error: %@", terminal);
            _storeString = [NSString stringWithFormat:@"%@/%@", pair.firstObject, terminal];
        } else if (pair.count > 1) {
            _storeString = pair.firstObject;
        }
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

- (instancetype)naked {
    if (_terminal) {
        if (_name) {
            return [[[self class] alloc] initWithName:_name
                                              address:_address];
        } else {
            return [[[self class] alloc] initWithAddress:_address];
        }
    } else {
        return self;
    }
}

@end
