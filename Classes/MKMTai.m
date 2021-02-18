// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
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
//  MKMTai.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMDataCoder.h"
#import "MKMDataParser.h"

#import "MKMAsymmetricKey.h"

#import "MKMID.h"

#import "MKMProfile.h"

@interface MKMDocument ()

@property (strong, nonatomic) id<MKMID> ID;

@property (strong, nonatomic) NSData *data;      // JsON.encode(properties)
@property (strong, nonatomic) NSData *signature; // User(ID).sign(data)

@property (strong, nonatomic) NSMutableDictionary *properties;

@property (nonatomic) NSInteger status;          // 1 for valid, -1 for invalid

@end

@implementation MKMDocument

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    NSDictionary *dict = nil;
    return [self initWithDictionary:dict];
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _ID = nil;
        
        _data = nil;
        _signature = nil;
        
        _properties = nil;

        _status = 0;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(id<MKMID>)ID
                      data:(NSData *)json
                 signature:(NSData *)signature {
    if (self = [super initWithDictionary:@{@"ID": ID}]) {
        // ID
        _ID = ID;

        _data = json;
        _signature = signature;
        
        [self setObject:MKMUTF8Decode(json) forKey:@"data"];
        [self setObject:MKMBase64Encode(signature) forKey:@"signature"];
        
        _properties = nil;

        // all documents must be verified before saving into local storage
        _status = 1;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(id<MKMID>)ID type:(NSString *)type {
    if (self = [super initWithDictionary:@{@"ID": ID}]) {
        // ID
        _ID = ID;
        
        _data = nil;
        _signature = nil;
        
        if (type.length > 0) {
            _properties = [[NSMutableDictionary alloc] init];
            [_properties setObject:type forKey:@"type"];
        } else {
            _properties = nil;
        }

        _status = 0;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    MKMDocument *doc = [super copyWithZone:zone];
    if (doc) {
        doc.ID = _ID;
        doc.data = _data;
        doc.signature = _signature;
        doc.properties = _properties;
        doc.status = _status;
    }
    return doc;
}

- (BOOL)isValid {
    return _status > 0;
}

- (NSData *)data {
    if (!_data) {
        NSString *json = [self objectForKey:@"data"];
        if (json.length > 0) {
            _data = MKMUTF8Encode(json);
        }
    }
    return _data;
}

- (NSData *)signature {
    if (!_signature) {
        NSString *sig = [self objectForKey:@"signature"];
        if (sig.length > 0) {
            _signature = MKMBase64Decode(sig);
        }
    }
    return _signature;
}

- (NSMutableDictionary *)properties {
    if (_status < 0) {
        // document invalid
        return nil;
    }
    if (!_properties) {
        NSData *data = [self data];
        if (data) {
            NSDictionary *dict = MKMJSONDecode(data);
            NSAssert(dict, @"document data error: %@", data);
            if ([dict isKindOfClass:[NSMutableDictionary class]]) {
                _properties = (NSMutableDictionary *)dict;
            } else {
                _properties = [dict mutableCopy];
            }
        } else {
            _properties = [[NSMutableDictionary alloc] init];
        }
    }
    return _properties;
}

- (NSArray *)propertyKeys {
    return [self.properties allKeys];
}

- (nullable NSObject *)propertyForKey:(NSString *)key {
    NSObject *property = [self.properties objectForKey:key];
    if (property == [NSNull null]) {
        return nil;
    }
    return property;
}

- (void)setProperty:(nullable NSObject *)value forKey:(NSString *)key {
    // 1. reset status
    NSAssert(_status >= 0, @"status error: %@", self);
    _status = 0;
    
    // 2. update property value with name
    NSMutableDictionary *mDict = self.properties;
    NSAssert(mDict, @"failed to get properties: %@", self);
    if (value) {
        [mDict setObject:value forKey:key];
    } else {
        [mDict removeObjectForKey:key];
    }
    
    // 3. clear data signature after properties changed
    [self removeObjectForKey:@"data"];
    [self removeObjectForKey:@"signature"];
    _data = nil;
    _signature = nil;
}

- (BOOL)verify:(id<MKMVerifyKey>)PK {
    if (_status > 0) {
        // already verify OK
        return YES;
    }
    NSData *data = self.data;
    NSData *signature = self.signature;
    if ([data length] == 0) {
        // NOTICE: if data is empty, signature should be empty at the same time
        //         this happen while document not found
        if ([signature length] == 0) {
            _status = 0;
        } else {
            // data signature error
            _status = -1;
        }
    } else if ([signature length] == 0) {
        // signature error
        _status = -1;
    } else if ([PK verify:data withSignature:signature]) {
        // signature matched
        _status = 1;
    }
    // NOTICE: if status is 0, it doesn't mean the document is invalid,
    //         try another key
    return _status == 1;
}

- (NSData *)sign:(id<MKMSignKey>)SK {
    if (_status > 0) {
        // already signed/verified
        NSAssert([_data length] > 0, @"document data error");
        NSAssert([_signature length] > 0, @"document signature error");
        return _signature;
    }
    _status = 1;
    _data = MKMJSONEncode(self.properties);
    _signature = [SK sign:_data];
    // update 'data' & 'signature' fields
    [self setObject:MKMUTF8Decode(_data) forKey:@"data"];
    [self setObject:MKMBase64Encode(_signature) forKey:@"signature"];
    return _signature;
}

+ (NSString *)type:(NSDictionary *)doc {
    return [doc objectForKey:@"type"];
}

- (NSString *)type {
    return [MKMDocument type:self.dictionary];
}

+ (id<MKMID>)ID:(NSDictionary *)doc {
    return MKMIDFromString([doc objectForKey:@"ID"]);
}

- (id<MKMID>)ID {
    if (!_ID) {
        _ID = [MKMDocument ID:self.dictionary];
    }
    return _ID;
}

#pragma mark properties getter/setter

- (NSString *)name {
    return (NSString *)[self propertyForKey:@"name"];
}

- (void)setName:(NSString *)name {
    [self setProperty:name forKey:@"name"];
}

@end

#pragma mark - Creation

@implementation MKMDocument (Creation)

static NSMutableDictionary<NSString *, id<MKMDocumentFactory>> *s_factories = nil;

+ (void)setFactory:(id<MKMDocumentFactory>)factory forType:(NSString *)type {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //if (!s_factories) {
            s_factories = [[NSMutableDictionary alloc] init];
        //}
    });
    [s_factories setObject:factory forKey:type];
}

+ (id<MKMDocumentFactory>)factoryForType:(NSString *)type {
    NSAssert(s_factories, @"document factories not set yet");
    return [s_factories objectForKey:type];
}

+ (__kindof id<MKMDocument>)create:(id<MKMID>)ID type:(NSString *)type data:(NSData *)data signature:(NSData *)CT {
    id<MKMDocumentFactory> factory = [self factoryForType:type];
    NSAssert(factory, @"document type not found: %@", type);
    return [factory createDocument:ID data:data signature:CT];
}

+ (__kindof id<MKMDocument>)create:(id<MKMID>)ID type:(NSString *)type {
    id<MKMDocumentFactory> factory = [self factoryForType:type];
    NSAssert(factory, @"document type not found: %@", type);
    return [factory createDocument:ID];
}

+ (nullable __kindof id<MKMDocument>)parse:(NSDictionary *)doc {
    if (doc.count == 0) {
        return nil;
    } else if ([doc conformsToProtocol:@protocol(MKMDocument)]) {
        return (id<MKMDocument>)doc;
    } else if ([doc conformsToProtocol:@protocol(MKMDictionary)]) {
        doc = [(id<MKMDictionary>)doc dictionary];
    }
    NSString *type = [MKMDocument type:doc];
    id<MKMDocumentFactory> factory = [self factoryForType:type];
    if (!factory) {
        factory = [self factoryForType:@"*"]; // unknown
        NSAssert(factory, @"cannot parse document: %@", doc);
    }
    return [factory parseDocument:doc];
}

@end
