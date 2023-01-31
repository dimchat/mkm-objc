// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
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
//  MKMFactoryManager.m
//  MingKeMing
//
//  Created by Albert Moky on 2023/1/31.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "MKMWrapper.h"
#import "MKMDataParser.h"
#import "MKMAsymmetricKey.h"

#import "MKMFactoryManager.h"

@implementation MKMFactoryManager

static MKMFactoryManager *s_manager = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [super allocWithZone:zone];
        s_manager.generalFactory = [[MKMGeneralFactory alloc] init];
    });
    return s_manager;
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[self alloc] init];
    });
    return s_manager;
}

@end

#pragma mark -

@interface MKMGeneralFactory () {
    
    id<MKMAddressFactory>                                    _addressFactory;
    id<MKMIDFactory>                                         _idFactory;
    NSMutableDictionary<NSNumber *, id<MKMMetaFactory>>     *_metaFactories;
    NSMutableDictionary<NSString *, id<MKMDocumentFactory>> *_documentFactories;
}

@end

@implementation MKMGeneralFactory

- (instancetype)init {
    if ([super init]) {
        _addressFactory = nil;
        _idFactory = nil;
        _metaFactories   = [[NSMutableDictionary alloc] init];
        _documentFactories    = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark Address

- (void)setAddressFactory:(id<MKMAddressFactory>)factory {
    _addressFactory = factory;
}

- (nullable id<MKMAddressFactory>)addressFactory {
    return _addressFactory;
}

- (nullable id<MKMAddress>)generateAddressWithType:(MKMEntityType)network
                                              meta:(id<MKMMeta>)meta {
    id<MKMAddressFactory> factory = [self addressFactory];
    NSAssert(factory, @"address factory not set");
    return [factory generateAddressWithMeta:meta type:network];
}

- (nullable id<MKMAddress>)createAddress:(NSString *)address {
    id<MKMAddressFactory> factory = [self addressFactory];
    NSAssert(factory, @"address factory not set");
    return [factory createAddress:address];
}

- (nullable id<MKMAddress>)parseAddress:(id)address {
    if (!address) {
        return nil;
    } else if ([address conformsToProtocol:@protocol(MKMAddress)]) {
        return (id<MKMAddress>)address;
    }
    NSString *string = MKMGetString(address);
    NSAssert([string isKindOfClass:[NSString class]], @"address error: %@", address);
    id<MKMAddressFactory> factory = [self addressFactory];
    NSAssert(factory, @"address factory not set");
    return [factory parseAddress:string];
}

#pragma mark ID

- (void)setIDFactory:(id<MKMIDFactory>)factory {
    _idFactory = factory;
}

- (nullable id<MKMIDFactory>)idFactory {
    return _idFactory;
}

- (nullable id<MKMID>)generateIDWithType:(MKMEntityType)network
                                    meta:(id<MKMMeta>)meta
                                terminal:(nullable NSString *)location {
    id<MKMIDFactory> factory = [self idFactory];
    NSAssert(factory, @"id factory not set");
    return [factory generateIDWithMeta:meta type:network terminal:location];
}

- (nullable id<MKMID>)createID:(nullable NSString *)name
                       address:(id<MKMAddress>)main
                      terminal:(nullable NSString *)loc {
    id<MKMIDFactory> factory = [self idFactory];
    NSAssert(factory, @"id factory not set");
    return [factory createID:name address:main terminal:loc];
}

- (nullable id<MKMID>)parseID:(id)identifier {
    if (!identifier) {
        return nil;
    } else if ([identifier conformsToProtocol:@protocol(MKMID)]) {
        return (id<MKMID>)identifier;
    }
    NSString *string = MKMGetString(identifier);
    NSAssert([string isKindOfClass:[NSString class]], @"id error: %@", identifier);
    id<MKMIDFactory> factory = [self idFactory];
    NSAssert(factory, @"id factory not set");
    return [factory parseID:identifier];
}

- (NSArray<id<MKMID>> *)convertIDList:(NSArray<id> *)members {
    NSMutableArray<id<MKMID>> *array = [[NSMutableArray alloc] initWithCapacity:members.count];
    id<MKMID> ID;
    for (NSString *item in members) {
        ID = MKMIDParse(item);
        if (ID) {
            [array addObject:ID];
        }
    }
    return array;
}

- (NSArray<NSString *> *)revertIDList:(NSArray<id<MKMID>> *)members {
    NSMutableArray<NSString *> *array = [[NSMutableArray alloc] initWithCapacity:members.count];
    NSString *str;
    for (id<MKMID> item in members) {
        str = [item string];
        if (str) {
            [array addObject:str];
        }
    }
    return array;
}

#pragma mark Meta

- (void)setMetaFactory:(id<MKMMetaFactory>)factory forType:(MKMMetaType)version {
    [_metaFactories setObject:factory forKey:@(version)];
}

- (nullable id<MKMMetaFactory>)metaFactoryForType:(MKMMetaType)version {
    return [_metaFactories objectForKey:@(version)];
}

- (MKMMetaType)metaType:(NSDictionary<NSString *,id> *)meta {
    NSNumber *version = [meta objectForKey:@"type"];
    if (!version) {
        // compatible with v1.0
        version = [meta objectForKey:@"version"];
    }
    return [version unsignedCharValue];
}

- (nullable id<MKMMeta>)generateMetaWithType:(MKMMetaType)version
                                         key:(id<MKMSignKey>)sKey
                                        seed:(nullable NSString *)name {
    id<MKMMetaFactory> factory = [self metaFactoryForType:version];
    NSAssert(factory, @"meta type not support: %d", version);
    return [factory generateMetaWithKey:sKey seed:name];
}

- (nullable id<MKMMeta>)createMeta:(MKMMetaType)version
                               key:(id<MKMVerifyKey>)pKey
                              seed:(nullable NSString *)name
                       fingerprint:(nullable NSData *)signature {
    id<MKMMetaFactory> factory = [self metaFactoryForType:version];
    NSAssert(factory, @"meta type not support: %d", version);
    return [factory createMetaWithKey:pKey seed:name fingerprint:signature];
}

- (nullable id<MKMMeta>)parseMeta:(id)meta {
    if (!meta) {
        return nil;
    } else if ([meta conformsToProtocol:@protocol(MKMMeta)]) {
        return (id<MKMMeta>)meta;
    }
    NSDictionary<NSString *, id> *info = MKMGetMap(meta);
    NSAssert([info isKindOfClass:[NSDictionary class]], @"meta info error: %@", meta);
    MKMMetaType version = [self metaType:info];
    NSAssert(version > 0, @"meta type error: %@", meta);
    
    id<MKMMetaFactory> factory = [self metaFactoryForType:version];
    if (!factory) {
        factory = [self metaFactoryForType:0];  // unknown
        NSAssert(factory, @"cannot parse meta: %@", meta);
    }
    return [factory parseMeta:info];
}

- (BOOL)checkMeta:(id<MKMMeta>)meta {
    id<MKMVerifyKey> key = meta.key;
    // meta.key should not be empty
    if (key) {
        if (MKMMeta_HasSeed(meta.type)) {
            // check seed with signature
            NSString *seed = meta.seed;
            NSData *fingerprint = meta.fingerprint;
            // seed and fingerprint should not be empty
            if (seed.length > 0 && fingerprint.length > 0) {
                // verify fingerprint
                return [key verify:MKMUTF8Encode(seed) withSignature:fingerprint];
            }
        } else {
            // this meta has no seed, so no signature too
            return YES;
        }
    }
    return NO;
}

- (BOOL)isMeta:(id<MKMMeta>)meta matchID:(id<MKMID>)ID {
    // check ID.name
    NSString *name = ID.name;
    if (name) {
        if (![name isEqualToString:meta.seed]) {
            return NO;
        }
    } else if (meta.seed) {
        return NO;
    }
    // check ID.address
    id<MKMAddress> old = ID.address;
    id<MKMAddress> gen = MKMAddressGenerate(old.type, meta);
    return [old isEqual:gen];
}

- (BOOL)isMeta:(id<MKMMeta>)meta matchKey:(id<MKMVerifyKey>)pKey {
    if ([meta.key isEqual:pKey]) {
        // NOTICE: ID with BTC/ETH address has no username, so
        //         just compare the key.data to check matching
        return YES;
    }
    // check with seed & fingerprint
    if (MKMMeta_HasSeed(meta.type)) {
        // check whether keys equal by verifying signature
        return [pKey verify:MKMUTF8Encode(meta.seed) withSignature:meta.fingerprint];
    }
    return NO;
}

#pragma mark Document

- (void)setDocumentFactory:(id<MKMDocumentFactory>)factory forType:(NSString *)type {
    [_documentFactories setObject:factory forKey:type];
}

- (nullable id<MKMDocumentFactory>)documentFactoryForType:(NSString *)type {
    return [_documentFactories objectForKey:type];
}

- (nullable NSString *)documentType:(NSDictionary<NSString *,id> *)doc {
    return [doc objectForKey:@"type"];
}

- (nullable id<MKMDocument>)createDocument:(id<MKMID>)identifier
                                      type:(NSString *)type {
    id<MKMDocumentFactory> factory = [self documentFactoryForType:type];
    NSAssert(factory, @"doc type not support: %@", type);
    return [factory createDocument:identifier];
}

- (nullable id<MKMDocument>)createDocument:(id<MKMID>)identifier
                                      type:(NSString *)type
                                      data:(NSString *)json
                                 signature:(NSString *)base64 {
    id<MKMDocumentFactory> factory = [self documentFactoryForType:type];
    NSAssert(factory, @"doc type not support: %@", type);
    return [factory createDocument:identifier data:json signature:base64];
}

- (nullable id<MKMDocument>)parseDocument:(id)doc {
    if (!doc) {
        return nil;
    } else if ([doc conformsToProtocol:@protocol(MKMDocument)]) {
        return (id<MKMDocument>)doc;
    }
    NSDictionary<NSString *, id> *info = MKMGetMap(doc);
    NSAssert([info isKindOfClass:[NSDictionary class]], @"doc info error: %@", doc);
    NSString *type = [self documentType:info];
    //NSAssert(type, @"doc type error: %@", doc);
    
    id<MKMDocumentFactory> factory = [self documentFactoryForType:type];
    if (!factory) {
        factory = [self documentFactoryForType:@"*"]; // unknown
        NSAssert(factory, @"cannot parse doc: %@", doc);
    }
    return [factory parseDocument:info];
}

@end
