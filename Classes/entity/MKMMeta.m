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

@implementation MKMMeta

+ (instancetype)metaWithMeta:(id)meta {
    if ([meta isKindOfClass:[MKMMeta class]]) {
        return meta;
    } else if ([meta isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:meta];
    } else if ([meta isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:meta];
    } else {
        NSAssert(!meta, @"unexpected meta: %@", meta);
        return nil;
    }
}

typedef NSMutableDictionary<const NSNumber *, Class> MKMMetaClassMap;

static MKMMetaClassMap *s_metaClasses = nil;

+ (MKMMetaClassMap *)metaClasses {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MKMMetaClassMap *map = [[NSMutableDictionary alloc] init];
        // MKM
        [map setObject:[MKMMetaDefault class] forKey:@(MKMMetaVersion_MKM)];
        // BTC
        [map setObject:[MKMMetaBTC class] forKey:@(MKMMetaVersion_BTC)];
        [map setObject:[MKMMetaBTC class] forKey:@(MKMMetaVersion_ExBTC)];
        // ...
        s_metaClasses = map;
    });
    return s_metaClasses;
}

+ (void)registerClass:(nullable Class)metaClass forVersion:(NSUInteger)version {
    NSAssert([metaClass isSubclassOfClass:self], @"class error: %@", metaClass);
    if (metaClass) {
        [[self metaClasses] setObject:metaClass forKey:@(version)];
    } else {
        [[self metaClasses] removeObjectForKey:@(version)];
    }
}

+ (nullable Class)classForVersion:(NSUInteger)version {
    return [[self metaClasses] objectForKey:@(version)];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if ([self isMemberOfClass:[MKMMeta class]]) {
        // create instance by subclass with meta version
        // version
        NSNumber *ver = [dict objectForKey:@"version"];
        NSUInteger version = [ver unsignedIntegerValue];
        Class clazz = [[self class] classForVersion:version];
        if (clazz) {
            self = [[clazz alloc] initWithDictionary:dict];
        } else {
            NSAssert(false, @"meta version not supported: %@", ver);
            self = nil;
        }
    } else if (self = [super initWithDictionary:dict]) {
        // version
        NSNumber *ver = [dict objectForKey:@"version"];
        NSUInteger version = [ver unsignedIntegerValue];
        // public key
        NSDictionary *key = [dict objectForKey:@"key"];
        MKMPublicKey *PK = [MKMPublicKey keyWithKey:key];
        
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
                      publicKey:(const MKMPublicKey *)PK
                           seed:(nullable const NSString *)name
                    fingerprint:(nullable const NSData *)CT {
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
        _seed = [name copy];
        _fingerprint = CT;
    }
    return self;
}

- (instancetype)initWithVersion:(NSUInteger)version
                           seed:(const NSString *)name
                     privateKey:(const MKMPrivateKey *)SK
                      publicKey:(const MKMPublicKey *)PK {
    if (PK) {
        NSAssert([PK isMatch:SK], @"PK must match SK");
    } else {
        PK = [SK publicKey];
    }
    NSData *CT = [SK sign:[name data]];
    return [self initWithVersion:version publicKey:PK seed:name fingerprint:CT];
}

- (instancetype)initWithPublicKey:(const MKMPublicKey *)PK {
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

- (BOOL)matchPublicKey:(const MKMPublicKey *)PK {
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

- (BOOL)matchID:(const MKMID *)ID {
    return [ID isEqual:[self generateID:ID.address.network]];
}

- (BOOL)matchAddress:(const MKMAddress *)address {
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

#pragma mark -

@implementation MKMMetaDefault

- (MKMAddress *)generateAddress:(MKMNetworkType)type {
    NSAssert(_version == MKMMetaVersion_MKM, @"meta version error");
    return [[MKMAddressBTC alloc] initWithData:_fingerprint network:type];
}

@end

@implementation MKMMetaBTC

- (MKMAddress *)generateAddress:(MKMNetworkType)type {
    NSAssert(_version & MKMMetaVersion_BTC, @"meta version error");
    return [[MKMAddressBTC alloc] initWithData:_key.data network:type];
}

@end
