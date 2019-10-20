//
//  MKMMeta.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
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

#pragma mark - Default Meta

/**
 *  Default Meta to build ID with 'name@address'
 *
 *  version:
 *      0x01 - MKM
 */
@interface MKMMetaDefault : MKMMeta

@end

@implementation MKMMetaDefault

- (MKMAddress *)generateAddress:(MKMNetworkType)type {
    NSAssert(self.version == MKMMetaVersion_MKM, @"meta version error");
    return [MKMAddressDefault generateWithData:self.fingerprint network:type];
}

@end

#pragma mark - Runtime

static NSMutableDictionary<NSNumber *, Class> *meta_classes(void) {
    static NSMutableDictionary<NSNumber *, Class> *classes = nil;
    SingletonDispatchOnce(^{
        classes = [[NSMutableDictionary alloc] init];
        // MKM
        [classes setObject:[MKMMetaDefault class] forKey:@(MKMMetaVersion_MKM)];
        // BTC, ExBTC
        // ETH, EXETH
        // ...
    });
    return classes;
}

@implementation MKMMeta (Runtime)

+ (void)registerClass:(nullable Class)clazz forVersion:(NSUInteger)version {
    if (clazz) {
        NSAssert([clazz isSubclassOfClass:self], @"error: %@", clazz);
        [meta_classes() setObject:clazz forKey:@(version)];
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
        // create instance by subclass with meta version
        NSNumber *version = [meta objectForKey:@"version"];
        Class clazz = [meta_classes() objectForKey:version];
        if (clazz) {
            return [clazz getInstance:meta];
        }
        NSAssert(false, @"meta not support: %@", meta);
        return nil;
    }
    // subclass
    return [[self alloc] initWithDictionary:meta];
}

@end
