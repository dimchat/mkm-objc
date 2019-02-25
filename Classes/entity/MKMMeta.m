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

@interface MKMMeta ()

@property (nonatomic) NSUInteger version;

@property (strong, nonatomic, nullable) NSString *seed;
@property (strong, nonatomic) MKMPublicKey *key;
@property (strong, nonatomic, nullable) NSData *fingerprint;

@property (nonatomic, getter=isValid) BOOL valid;

@end

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

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _version = 0;
        _seed = nil;
        _key = nil;
        _fingerprint = nil;
        _valid = NO;
    }
    return self;
}

- (instancetype)initWithSeed:(nullable const NSString *)name
                   publicKey:(const MKMPublicKey *)PK
                 fingerprint:(nullable const NSData *)CT
                     version:(NSUInteger)metaVersion {
    NSDictionary *dict;
    if (metaVersion == MKMMetaVersion_MKM ||
        metaVersion == MKMMetaVersion_ExBTC) {
        dict = @{@"version"    :@(metaVersion),
                 @"seed"       :name,
                 @"key"        :PK,
                 @"fingerprint":[CT base64Encode],
                 };
    } else if (metaVersion == MKMMetaVersion_BTC) {
        NSAssert(!name && !CT, @"parameters error");
        dict = @{@"version"    :@(metaVersion),
                 @"key"        :PK,
                 };
    } else {
        NSAssert(false, @"unsupported meta version: %lu", (unsigned long)metaVersion);
    }
    if (self = [super initWithDictionary:dict]) {
        _version = metaVersion;
        _seed = [_storeDictionary objectForKey:@"seed"];
        _key = [_storeDictionary objectForKey:@"key"];
        _fingerprint = [CT copy];
        if (metaVersion == MKMMetaVersion_MKM ||
            metaVersion == MKMMetaVersion_ExBTC) {
            _valid = [PK verify:[name data] withSignature:CT];
        } else if (metaVersion == MKMMetaVersion_BTC) {
            _valid = YES;
        } else {
            _valid = NO;
        }
        NSAssert(_valid, @"meta invalid");
    }
    return self;
}

- (instancetype)initWithSeed:(const NSString *)name
                  privateKey:(const MKMPrivateKey *)SK
                   publicKey:(nullable const MKMPublicKey *)PK
                     version:(NSUInteger)metaVersion {
    if (PK) {
        NSAssert([PK isMatch:SK], @"PK must match SK");
    } else {
        PK = [SK publicKey];
    }
    NSData *CT = [SK sign:[name data]];
    return [self initWithSeed:name
                    publicKey:PK
                  fingerprint:CT
                      version:metaVersion];
}

- (instancetype)initWithPublicKey:(const MKMPublicKey *)PK {
    return [self initWithSeed:nil
                    publicKey:PK
                  fingerprint:nil
                      version:MKMMetaVersion_BTC];
}

- (id)copyWithZone:(NSZone *)zone {
    MKMMeta *meta = [super copyWithZone:zone];
    if (meta) {
        meta.version = _version;
        meta.seed = _seed;
        meta.key = _key;
        meta.fingerprint = _fingerprint;
        meta.valid = _valid;
    }
    return meta;
}

- (NSUInteger)version {
    if (_version == 0) {
        NSNumber *ver = [_storeDictionary objectForKey:@"version"];
        _version = [ver unsignedIntegerValue];
    }
    return _version;
}

- (NSString *)seed {
    if (!_seed) {
        _seed = [_storeDictionary objectForKey:@"seed"];
        // check valid
        if (_key && _fingerprint) {
            _valid = [_key verify:[_seed data] withSignature:_fingerprint];
        }
    }
    return _seed;
}

- (MKMPublicKey *)key {
    if (!_key) {
        id key = [_storeDictionary objectForKey:@"key"];
        _key = [MKMPublicKey keyWithKey:key];
        NSAssert([_key isKindOfClass:[MKMPublicKey class]], @"error");
        // check valid
        if (_seed && _fingerprint) {
            _valid = [_key verify:[_seed data] withSignature:_fingerprint];
        }
    }
    return _key;
}

- (NSData *)fingerprint {
    if (!_fingerprint) {
        NSString *CT = [_storeDictionary objectForKey:@"fingerprint"];
        _fingerprint = [CT base64Decode];
        // check valid
        if (_seed && _key) {
            _valid = [_key verify:[_seed data] withSignature:_fingerprint];
        }
    }
    return _fingerprint;
}

- (BOOL)isValid {
    if (!_valid) {
        switch (self.version) {
            case MKMMetaVersion_MKM: {
                if (!self.seed || !self.key || !self.fingerprint) {
                    NSAssert(false, @"meta error");
                    return NO;
                } else {
                    _valid = YES;
                }
            }
                break;
                
            case MKMMetaVersion_BTC: {
                if (!self.key) {
                    NSAssert(false, @"meta error");
                    return NO;
                } else {
                    _valid = YES;
                }
            }
                break;
                
            case MKMMetaVersion_ExBTC: {
                if (!self.seed || !self.key || !self.fingerprint) {
                    NSAssert(false, @"meta error");
                    return NO;
                } else {
                    _valid = YES;
                }
            }
                break;
                
            default:
                NSAssert(false, @"meta error");
                return NO;
                break;
        }
        //NSAssert(_valid, @"meta invalid");
    }
    return _valid;
}

#pragma mark - ID & address

- (BOOL)matchID:(const MKMID *)ID {
    NSAssert(ID.isValid, @"Invalid ID");
    MKMID *str = [self buildIDWithNetworkID:ID.type];
    return [ID isEqualToString:str];
}

// check: address == btc_address(network, CT)
- (BOOL)matchAddress:(const MKMAddress *)address {
    NSAssert(address.isValid, @"Invalid address");
    MKMAddress *addr = [self buildAddressWithNetworkID:address.network];
    return [address isEqualToString:addr];
}

- (MKMID *)buildIDWithNetworkID:(MKMNetworkType)type {
    MKMAddress *addr = [self buildAddressWithNetworkID:type];
    if (!addr) {
        NSAssert(false, @"failed to build ID");
        return nil;
    }
    switch (self.version) {
        case MKMMetaVersion_MKM:
        case MKMMetaVersion_ExBTC:
            return [[MKMID alloc] initWithName:self.seed address:addr];
            
        case MKMMetaVersion_BTC:
            NSAssert(self.seed.length == 0, @"meta version error");
            return [[MKMID alloc] initWithAddress:addr];
            
        default:
            break;
    }
    NSAssert(false, @"meta version error");
    return nil;
}

- (MKMAddress *)buildAddressWithNetworkID:(MKMNetworkType)type {
    if (!self.isValid) {
        NSAssert(false, @"meta not valid");
        return nil;
    }
    switch (self.version) {
        case MKMMetaVersion_MKM:
            return [[MKMAddress alloc] initWithFingerprint:self.fingerprint
                                                   network:type];
            
        case MKMMetaVersion_BTC:
        case MKMMetaVersion_ExBTC:
            NSAssert(type == MKMNetwork_BTCMain, @"address type error");
            return [[MKMAddress alloc] initWithKeyData:self.key.data
                                               network:type];
            
        default:
            break;
    }
    NSAssert(false, @"meta version error");
    return nil;
}

@end
