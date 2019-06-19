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
    MKMID *ID = MKMIDFromString(object);
    // check name
    if (NSStringNotEquals(_name, ID.name)) {
        return NO;
    }
    // compare address
    return [_address isEqual:ID.address];
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

@implementation MKMID (Runtime)

+ (nullable instancetype)getInstance:(id)ID {
    if (!ID) {
        return nil;
    }
    if ([ID isKindOfClass:[MKMID class]]) {
        // return ID object directly
        return ID;
    }
    NSAssert([ID isKindOfClass:[NSString class]],
             @"ID should be a string: %@", ID);
    return [[self alloc] initWithString:ID];
}

@end
