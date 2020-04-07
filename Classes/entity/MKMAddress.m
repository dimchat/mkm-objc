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
//  MKMAddress.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSData+Crypto.h"

#import "MKMBaseCoder.h"

#import "MKMAddress.h"

@interface MKMAddress ()

@property (nonatomic) MKMNetworkType network; // Network ID
@property (nonatomic) UInt32 code;            // Check Code

@end

@implementation MKMAddress

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    NSString *string = nil;
    return [self initWithString:string];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSAssert(false, @"DON'T call me!");
    NSString *string = nil;
    return [self initWithString:string];
}

/* designated initializer */
- (instancetype)initWithString:(NSString *)aString {
    if (self = [super initWithString:aString]) {
        _network = 0;
        _code = 0;
    }
    return self;
}

- (NSString *)description {
    return _storeString;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: 0x%02X | %010u \"%@\">",
            [self class], self.network, self.code, _storeString];
}

@end

#pragma mark - Constant Addresses

static inline MKMAddress *anywhere(void) {
    static MKMAddress *s_anywhere = nil;
    SingletonDispatchOnce(^{
        s_anywhere = [[MKMAddress alloc] initWithString:@"anywhere"];
        s_anywhere.network = MKMNetwork_Main;
        s_anywhere.code = 9527;
    });
    return s_anywhere;
}

static inline MKMAddress *everywhere(void) {
    static MKMAddress *s_everywhere = nil;
    SingletonDispatchOnce(^{
        s_everywhere = [[MKMAddress alloc] initWithString:@"everywhere"];
        s_everywhere.network = MKMNetwork_Group;
        s_everywhere.code = 9527;
    });
    return s_everywhere;
}

@implementation MKMAddress (AddressType)

- (BOOL)isBroadcast {
    if (self.network == MKMNetwork_Main) {
        // user address
        return [anywhere() isEqual:self];
    }
    if (self.network == MKMNetwork_Group) {
        // group address
        return [everywhere() isEqual:self];
    }
    return NO;
}

- (BOOL)isUser {
    return MKMNetwork_IsUser([self network]);
}

- (BOOL)isGroup {
    return MKMNetwork_IsGroup([self network]);
}

@end

#pragma mark - Runtime

static NSMutableArray<Class> *address_classes(void) {
    static NSMutableArray<Class> *classes = nil;
    SingletonDispatchOnce(^{
        classes = [[NSMutableArray alloc] init];
        // Default (BTC)
        [classes addObject:[MKMAddressDefault class]];
        // ETH
        // ...
    });
    return classes;
}

@implementation MKMAddress (Runtime)

+ (void)registerClass:(Class)clazz {
    NSAssert([clazz isSubclassOfClass:self], @"address class error: %@", clazz);
    NSMutableArray<Class> *classes = address_classes();
    if (clazz && ![classes containsObject:clazz]) {
        // parse address string with new class first
        [classes insertObject:clazz atIndex:0];
    }
}

+ (nullable instancetype)getInstance:(id)address {
    if (!address) {
        return nil;
    }
    if ([address isKindOfClass:[MKMAddress class]]) {
        // return Address object directly
        return address;
    }
    NSAssert([address isKindOfClass:[NSString class]], @"address error: %@", address);
    
    /**
     *  Address for broadcast
     */
    NSUInteger length = [address length];
    if (length == 8 && [[address lowercaseString] isEqualToString:anywhere()]) {
        // anywhere
        return anywhere();
    }
    if (length == 10 && [[address lowercaseString] isEqualToString:everywhere()]) {
        // everywhere
        return everywhere();
    }
    
    // create instance by subclass
    NSMutableArray<Class> *classes = address_classes();
    for (Class clazz in classes) {
        @try {
            // create instance with subclass of Address
            return [[clazz alloc] initWithString:address];
        } @catch (NSException *exception) {
            // address format error, try next
        } @finally {
            //
        }
    }
    NSAssert(false, @"address not support: %@", address);
    return nil;
}

@end

#pragma mark - Default Address Algorithm (BTC)

/**
 *  Get check code of the address
 *
 * @param data - network + hash(CT)
 * @return prefix 4 bytes after sha256*2
 */
static inline NSData * check_code(NSData *data) {
    assert([data length] == 21);
    data = [[data sha256] sha256];
    return [data subdataWithRange:NSMakeRange(0, 4)];
}

/**
 *  Get user number, which for remembering and searching user
 *
 * @param cc - check code
 * @return unsigned integer
 */
static inline UInt32 user_number(NSData *cc) {
    assert([cc length] == 4);
    UInt32 number;
    memcpy(&number, [cc bytes], sizeof(UInt32));
    return number;
}

@implementation MKMAddressDefault

- (instancetype)initWithString:(NSString *)aString {
    NSAssert(aString.length >= 15, @"address invalid: %@", aString);
    if (self = [super initWithString:aString]) {
        // Parse string with BTC address format
        NSData *data = MKMBase58Decode(aString);
        NSUInteger len = [data length];
        if (len != 25) {
            @throw [NSException exceptionWithName:NSRangeException
                                           reason:@"BTC address length error"
                                         userInfo:nil];
        }
        // Check Code
        NSData *prefix = [data subdataWithRange:NSMakeRange(0, len-4)];
        NSData *suffix = [data subdataWithRange:NSMakeRange(len-4, 4)];
        NSData *cc = check_code(prefix);
        // isValid
        if (![cc isEqualToData:suffix]) {
            @throw [NSException exceptionWithName:NSGenericException
                                           reason:@"BTC check code error"
                                         userInfo:nil];
        }
        // Network ID
        const unsigned char *bytes = (const unsigned char *)[data bytes];
        self.network = bytes[0];
        self.code = user_number(cc);
    }
    return self;
}

/**
 *  BTC address algorithm:
 *      digest     = ripemd160(sha256(fingerprint));
 *      check_code = sha256(sha256(network + digest)).prefix(4);
 *      addr       = base58_encode(network + digest + check_code);
 */
- (instancetype)initWithData:(NSData *)key
                     network:(MKMNetworkType)type {
    NSString *string = nil;
    UInt32 code = 0;
    
    // 1. hash = ripemd160(sha256(CT))
    NSData *hash = [[key sha256] ripemd160];
    // 2. _h = network + hash
    NSMutableData *data;
    data = [[NSMutableData alloc] initWithBytes:&type length:1];
    [data appendData:hash];
    // 3. cc = sha256(sha256(_h)).prefix(4)
    NSData *cc = check_code(data);
    code = user_number(cc);
    // 4. addr = base58_encode(_h + cc)
    [data appendData:cc];
    string = MKMBase58Encode(data);
    
    if (self = [super initWithString:string]) {
        self.network = type;
        self.code = code;
    }
    return self;
}

+ (instancetype)generateWithData:(NSData *)key network:(MKMNetworkType)type {
    return [[self alloc] initWithData:key network:type];
}

@end
