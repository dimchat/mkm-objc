//
//  MKMMeta.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"

#import "MKMMeta.h"

@interface MKMMeta () {
    
    NSUInteger _version;
    MKMPublicKey *_key;
    NSString *_seed;
    NSData *_fingerprint;
}

@end

@implementation MKMMeta

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // version
        NSNumber *ver = [dict objectForKey:@"version"];
        NSUInteger version = [ver unsignedIntegerValue];
        // public key
        NSDictionary *key = [dict objectForKey:@"key"];
        MKMPublicKey *PK = MKMPublicKeyFromDictionary(key);
        
        if (version & MKMMetaVersion_MKM) { // MKM, ExBTC, ExETH, ...
            // seed
            NSString *seed = [dict objectForKey:@"seed"];
            // fingerprint
            NSString *fingerprint = [dict objectForKey:@"fingerprint"];
            NSData *CT = [fingerprint base64Decode];
            
            if (![PK verify:[seed data] withSignature:CT]) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException
                                               reason:@"Meta key not match"
                                             userInfo:dict];
            }
            _seed = seed;
            _fingerprint = CT;
        } else { // BTC, ETH, ...
            _seed = nil;
            _fingerprint = nil;
        }
        _version = version;
        _key = PK;
    }
    return self;
}

- (instancetype)initWithVersion:(NSUInteger)version
                      publicKey:(MKMPublicKey *)PK
                           seed:(nullable NSString *)name
                    fingerprint:(nullable NSData *)CT {
    NSAssert(PK, @"meta.key cannot be empty");
    NSDictionary *dict;
    if (version & MKMMetaVersion_MKM) { // MKM, ExBTC, ExETH, ...
        dict = @{@"version"    :@(version),
                 @"key"        :PK,
                 @"seed"       :name,
                 @"fingerprint":[CT base64Encode],
                 };
    } else { // BTC, ETH, ...
        dict = @{@"version"    :@(version),
                 @"key"        :PK,
                 };
    }
    if (self = [super initWithDictionary:dict]) {
        _version = version;
        _key = PK;
        _seed = name;
        _fingerprint = CT;
    }
    return self;
}

- (instancetype)initWithVersion:(NSUInteger)version
                           seed:(NSString *)name
                     privateKey:(MKMPrivateKey *)SK
                      publicKey:(MKMPublicKey *)PK {
    if (PK) {
        NSAssert([PK isMatch:SK], @"PK must match SK");
    } else {
        PK = [SK publicKey];
    }
    NSData *CT = [SK sign:[name data]];
    return [self initWithVersion:version publicKey:PK seed:name fingerprint:CT];
}

- (instancetype)initWithPublicKey:(MKMPublicKey *)PK {
    NSAssert(PK, @"meta.key cannot be empty");
    NSUInteger version = MKMMetaVersion_BTC;
    
    NSDictionary *dict = @{@"version"    :@(version),
                           @"key"        :PK,
                           };
    if (self = [super initWithDictionary:dict]) {
        _version = version;
        _key = PK;
        _seed = nil;
        _fingerprint = nil;
    }
    return self;
}

- (BOOL)matchPublicKey:(MKMPublicKey *)PK {
    if ([PK isEqual:_key]) {
        return YES;
    }
    if (_version & MKMMetaVersion_MKM) { // MKM, ExBTC, ExETH, ...
        // check whether keys equal by verifying signature
        return [PK verify:[_seed data] withSignature:_fingerprint];
    } else { // BTC, ETH, ...
        // ID with BTC address has no username
        // so we can just compare the key.data to check matching
        return NO;
    }
}

#pragma mark - ID & address

- (BOOL)matchID:(MKMID *)ID {
    return [ID isEqual:[self generateID:ID.address.network]];
}

- (BOOL)matchAddress:(MKMAddress *)address {
    return [address isEqual:[self generateAddress:address.network]];
}

- (MKMID *)generateID:(MKMNetworkType)type {
    MKMAddress *address = [self generateAddress:type];
    return [[MKMID alloc] initWithName:_seed address:address];
}

- (MKMAddress *)generateAddress:(MKMNetworkType)type {
    NSAssert(_version == MKMMetaVersion_MKM, @"meta version error");
    return [[MKMAddressBTC alloc] initWithData:_fingerprint network:type];
}

@end

static inline NSMutableDictionary<NSNumber *, Class> *meta_classes(void) {
    static NSMutableDictionary<NSNumber *, Class> *classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = [[NSMutableDictionary alloc] init];
        // MKM
        //[classes setObject:[MKMMetaDefault class] forKey:@(MKMMetaVersion_MKM)];
        // BTC
        [classes setObject:[MKMMetaBTC class] forKey:@(MKMMetaVersion_BTC)];
        [classes setObject:[MKMMetaBTC class] forKey:@(MKMMetaVersion_ExBTC)];
        // ...
    });
    return classes;
}

@implementation MKMMeta (Runtime)

+ (void)registerClass:(nullable Class)metaClass forVersion:(NSUInteger)version {
    NSAssert(![metaClass isEqual:self], @"only subclass");
    NSAssert([metaClass isSubclassOfClass:self], @"class error: %@", metaClass);
    if (metaClass) {
        [meta_classes() setObject:metaClass forKey:@(version)];
    } else {
        [meta_classes() removeObjectForKey:@(version)];
    }
}

+ (nullable instancetype)getInstance:(id)meta {
    if (!meta) {
        return nil;
    }
    if ([meta isKindOfClass:[MKMMeta class]]) {
        // return Meta object directly
        return meta;
    }
    NSAssert([meta isKindOfClass:[NSDictionary class]],
             @"meta should be a dictionary: %@", meta);
    if (![self isEqual:[MKMMeta class]]) {
        // subclass
        NSAssert([self isSubclassOfClass:[MKMMeta class]], @"meta class error");
        return [[self alloc] initWithDictionary:meta];
    }
    // create instance by subclass with meta version
    NSNumber *version = [meta objectForKey:@"version"];
    Class clazz = [meta_classes() objectForKey:version];
    if (clazz) {
        return [clazz getInstance:meta];
    } else {
        return [[self alloc] initWithDictionary:meta];
    }
}

@end

#pragma mark -

@implementation MKMMetaBTC

- (MKMAddress *)generateAddress:(MKMNetworkType)type {
    NSAssert(self.version & MKMMetaVersion_BTC, @"meta version error");
    return [[MKMAddressBTC alloc] initWithData:self.key.data network:type];
}

@end
