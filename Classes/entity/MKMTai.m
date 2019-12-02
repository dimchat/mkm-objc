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
//  MKMTai.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+Singleton.h"
#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"

#import "MKMUser.h"

#import "MKMProfile.h"

@interface MKMTAI () {
    
    NSString *_ID;
    id<MKMEncryptKey> _key;
    
    NSMutableDictionary *_properties;
    
    NSData *_data;    // JsON.encode(properties)
    NSData *_signature; // User(ID).sign(data)
    
    NSInteger _status;
}

@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic, nullable) id<MKMEncryptKey> key;

@property (strong, nonatomic) NSMutableDictionary *properties;

@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) NSData *signature;

@property (nonatomic) NSInteger status;

@end

@implementation MKMTAI

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    NSDictionary *dict = nil;
    return [self initWithDictionary:dict];
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazi
        _ID = nil;
        
        _properties = nil;
        
        _data = nil; // JsON.encode(properties)
        _signature = nil; // User(ID).sign(data)
        
        _status = 0; // 1 for valid, -1 for invalid
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(MKMID *)ID
                      data:(NSData *)json
                 signature:(NSData *)signature {
    if (self = [super initWithDictionary:@{@"ID": ID}]) {
        // ID
        _ID = ID;
        
        _properties = nil;

        _data = json;
        _signature = signature;
        
        [self setObject:[json UTF8String] forKey:@"data"];
        [self setObject:[signature base64Encode] forKey:@"signature"];
        
        _status = 0; // 1 for valid, -1 for invalid
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(MKMID *)ID {
    NSAssert([ID isValid], @"profile ID error: %@", ID);
    if (self = [super initWithDictionary:@{@"ID": ID}]) {
        // ID
        _ID = ID;
        
        _properties = nil;
        
        _data = nil; // JsON.encode(properties)
        _signature = nil; // User(ID).sign(data)
        
        _status = 0; // 1 for valid, -1 for invalid
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMTAI *profile = [super copyWithZone:zone];
    if (profile) {
        profile.ID = _ID;
        profile.properties = _properties;
        profile.data = _data;
        profile.signature = _signature;
        profile.status = _status;
    }
    return profile;
}

- (BOOL)isValid {
    return _status >= 0;
}

- (NSString *)ID {
    if (!_ID) {
        _ID = [_storeDictionary objectForKey:@"ID"];
    }
    return _ID;
}

- (NSData *)data {
    if (!_data) {
        NSString *json = [_storeDictionary objectForKey:@"data"];
        _data = [json data];
    }
    return _data;
}

- (NSData *)signature {
    if (!_signature) {
        NSString *sig = [_storeDictionary objectForKey:@"signature"];
        _signature = [sig base64Decode];
    }
    return _signature;
}

- (NSMutableDictionary *)properties {
    if (_status < 0) {
        // profile invalid
        return nil;
    }
    if (!_properties) {
        NSData *data = [self data];
        if (data) {
            NSDictionary *dict = [data jsonDictionary];
            NSAssert(dict, @"profile data error: %@", data);
            _properties = [dict mutableCopy];
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
    return [self.properties objectForKey:key];
}

- (void)setProperty:(nullable NSObject *)value forKey:(NSString *)key {
    // 1. reset status
    NSAssert(_status >= 0, @"status error: %@", self);
    _status = 0;
    
    // 2. update property value with name
    NSMutableDictionary *mDict = self.properties;
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

- (nullable id<MKMEncryptKey>)key {
    NSAssert(false, @"override me!");
    return nil;
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
        //         this happen while profile not found
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
    // NOTICE: if status is 0, it doesn't mean the profile is invalid,
    //         try another key
    return _status == 1;
}

- (NSData *)sign:(id<MKMSignKey>)SK {
    if (_status == 1) {
        // already signed/verified
        NSAssert([_data length] > 0, @"profile data error");
        NSAssert([_signature length] > 0, @"profile signature error");
        return _signature;
    }
    _status = 1;
    _data = [self.properties jsonData];
    _signature = [SK sign:_data];
    // update 'data' & 'signature' fields
    [_storeDictionary setObject:[_data UTF8String] forKey:@"data"];
    [_storeDictionary setObject:[_signature base64Encode] forKey:@"signature"];
    return _signature;
}

@end
