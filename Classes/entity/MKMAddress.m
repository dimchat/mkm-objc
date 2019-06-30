//
//  MKMAddress.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

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

- (BOOL)isEqual:(id)object {
    return [_storeString isEqualToString:object];
}

@end

static NSMutableArray<Class> *address_classes(void) {
    static NSMutableArray<Class> *classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = [[NSMutableArray alloc] init];
        // BTC
        [classes addObject:[MKMAddressBTC class]];
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
    if ([address isEqualToString:@"EVERYWHERE"]) {
        static MKMAddress *everywhere = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            everywhere = [[MKMAddress alloc] initWithString:@"EVERYWHERE"];
            everywhere.network = MKMNetwork_Main;
            everywhere.code = 9527;
        });
        return everywhere;
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

#pragma mark - BTC Address

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

@implementation MKMAddressBTC

- (instancetype)initWithString:(NSString *)aString {
    NSAssert(aString.length >= 15, @"address invalid: %@", aString);
    if (self = [super initWithString:aString]) {
        // Parse string with BTC address format
        NSData *data = [aString base58Decode];
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
        const char *bytes = [data bytes];
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
    string = [data base58Encode];
    
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
