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

#import "MKMCopier.h"
#import "MKMWrapper.h"
#import "MKMDataParser.h"
#import "MKMTransportableData.h"
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
        _addressFactory    = nil;
        _idFactory         = nil;
        _metaFactories     = [[NSMutableDictionary alloc] init];
        _documentFactories = [[NSMutableDictionary alloc] init];
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

- (id<MKMAddress>)generateAddressWithType:(MKMEntityType)network
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

- (id<MKMID>)generateIdentifierWithType:(MKMEntityType)network
                                   meta:(id<MKMMeta>)meta
                               terminal:(nullable NSString *)location {
    id<MKMIDFactory> factory = [self idFactory];
    NSAssert(factory, @"ID factory not set");
    return [factory generateIdentifierWithMeta:meta type:network terminal:location];
}

- (id<MKMID>)createIdentifier:(nullable NSString *)name
                      address:(id<MKMAddress>)main
                     terminal:(nullable NSString *)loc {
    id<MKMIDFactory> factory = [self idFactory];
    NSAssert(factory, @"ID factory not set");
    return [factory createIdentifier:name address:main terminal:loc];
}

- (nullable id<MKMID>)parseIdentifier:(id)identifier {
    if (!identifier) {
        return nil;
    } else if ([identifier conformsToProtocol:@protocol(MKMID)]) {
        return (id<MKMID>)identifier;
    }
    NSString *string = MKMGetString(identifier);
    NSAssert([string isKindOfClass:[NSString class]], @"id error: %@", identifier);
    id<MKMIDFactory> factory = [self idFactory];
    NSAssert(factory, @"ID factory not set");
    return [factory parseIdentifier:string];
}

- (NSArray<id<MKMID>> *)convertIDList:(NSArray<id> *)members {
    NSMutableArray<id<MKMID>> *array = [[NSMutableArray alloc] initWithCapacity:members.count];
    id<MKMID> ID;
    for (id item in members) {
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

- (MKMMetaType)metaType:(NSDictionary<NSString *,id> *)meta
           defaultValue:(MKMMetaType)aValue {
    id version = [meta objectForKey:@"type"];
    NSAssert(version, @"meta type not found: %@", meta);
    return MKMConverterGetUnsignedChar(version, aValue);
}

- (id<MKMMeta>)generateMetaWithType:(MKMMetaType)version
                                key:(id<MKMSignKey>)sKey
                               seed:(nullable NSString *)name {
    id<MKMMetaFactory> factory = [self metaFactoryForType:version];
    NSAssert(factory, @"meta type not support: %d", version);
    return [factory generateMetaWithKey:sKey seed:name];
}

- (id<MKMMeta>)createMetaWithType:(MKMMetaType)version
                              key:(id<MKMVerifyKey>)pKey
                             seed:(nullable NSString *)name
                      fingerprint:(nullable id<MKMTransportableData>)signature {
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
    if (!info) {
        NSAssert(false, @"meta error: %@", meta);
        return nil;
    }
    MKMMetaType version = [self metaType:info defaultValue:0];
    NSAssert(version > 0, @"meta type error: %@", meta);
    id<MKMMetaFactory> factory = [self metaFactoryForType:version];
    if (!factory) {
        factory = [self metaFactoryForType:0];  // unknown
        NSAssert(factory, @"default meta factory not found");
    }
    return [factory parseMeta:info];
}

#pragma mark Document

- (void)setDocumentFactory:(id<MKMDocumentFactory>)factory forType:(NSString *)type {
    [_documentFactories setObject:factory forKey:type];
}

- (nullable id<MKMDocumentFactory>)documentFactoryForType:(NSString *)type {
    return [_documentFactories objectForKey:type];
}

- (nullable NSString *)documentType:(NSDictionary<NSString *,id> *)doc
                       defaultValue:(nullable NSString *)aValue {
    NSString *type = [doc objectForKey:@"type"];
    return MKMConverterGetString(type, aValue);
}

- (id<MKMDocument>)createDocument:(id<MKMID>)identifier
                             type:(NSString *)type
                             data:(NSString *)json
                        signature:(id<MKMTransportableData>)base64 {
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
    if (!info) {
        NSAssert(false, @"document error: %@", doc);
        return nil;
    }
    NSString *docType = [self documentType:info defaultValue:@"*"];
    id<MKMDocumentFactory> factory = [self documentFactoryForType:docType];
    if (!factory) {
        NSAssert(![docType isEqualToString:@"*"], @"document factory not ready: %@", doc);
        factory = [self documentFactoryForType:@"*"]; // unknown
        NSAssert(factory, @"default document factory not found");
    }
    return [factory parseDocument:info];
}

@end
