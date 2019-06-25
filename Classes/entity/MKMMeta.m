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

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    NSDictionary *dict = nil;
    return [self initWithDictionary:dict];
}

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

+ (instancetype)generateWithVersion:(NSUInteger)version
                         privateKey:(MKMPrivateKey *)SK
                               seed:(nullable NSString *)name {
    NSDictionary *dict;
    if (version & MKMMetaVersion_MKM) { // MKM, ExBTC, ExETH, ...
        NSData *CT = [SK sign:[name data]];
        NSString *fingerprint = [CT base64Encode];
        dict = @{@"version"    :@(version),
                 @"key"        :[SK publicKey],
                 @"seed"       :name,
                 @"fingerprint":fingerprint,
                 };
    } else { // BTC, ETH, ...
        dict = @{@"version"    :@(version),
                 @"key"        :[SK publicKey],
                 };
    }
    return [self getInstance:dict];
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
    NSAssert(false, @"override me!");
    return nil;
}

@end

static NSMutableDictionary<NSNumber *, Class> *meta_classes(void) {
    static NSMutableDictionary<NSNumber *, Class> *classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = [[NSMutableDictionary alloc] init];
        // MKM
        [classes setObject:[MKMMetaDefault class] forKey:@(MKMMetaVersion_MKM)];
        // BTC
        [classes setObject:[MKMMetaBTC class] forKey:@(MKMMetaVersion_BTC)];
        [classes setObject:[MKMMetaBTC class] forKey:@(MKMMetaVersion_ExBTC)];
        // ETH
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
    NSAssert([meta isKindOfClass:[NSDictionary class]], @"meta error: %@", meta);
    if ([self isEqual:[MKMMeta class]]) {
        // get subclass with meta version
        NSNumber *version = [meta objectForKey:@"version"];
        Class clazz = [meta_classes() objectForKey:version];
        if (clazz) {
            NSAssert([clazz isSubclassOfClass:self], @"class error: %@", clazz);
            return [clazz getInstance:meta];
        }
        NSAssert(false, @"meta not support: %@", meta);
        return nil;
    }
    // create instance with subclass of Meta
    return [[self alloc] initWithDictionary:meta];
}

@end

#pragma mark -

@implementation MKMMetaDefault

- (MKMAddress *)generateAddress:(MKMNetworkType)type {
    NSAssert(self.version == MKMMetaVersion_MKM, @"meta version error");
    return [MKMAddressBTC generateWithData:self.fingerprint network:type];
}

@end

@implementation MKMMetaBTC

- (MKMAddress *)generateAddress:(MKMNetworkType)type {
    NSAssert(self.version & MKMMetaVersion_BTC, @"meta version error");
    return [MKMAddressBTC generateWithData:self.key.data network:type];
}

@end
