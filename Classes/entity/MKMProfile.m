//
//  MKMProfile.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSData+Crypto.h"
#import "NSString+Crypto.h"

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"

#import "MKMAccount.h"
#import "MKMUser.h"

#import "MKMProfile.h"

@interface MKMTAO () {
    
    const MKMID *_ID;
    
    NSString *_data;    // JsON.encode(properties)
    NSData *_signature; // User(ID).sign(data)
    
    NSMutableDictionary *_properties;
    
    MKMPublicKey *_key;
    
    BOOL _valid; // YES on signature matched
}

@end

@implementation MKMTAO

+ (instancetype)profileWithProfile:(id)profile {
    if ([profile isKindOfClass:[MKMProfile class]]) {
        return profile;
    } else if ([profile isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:profile];
    } else if ([profile isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:profile];
    } else {
        NSAssert(!profile, @"unexpected profile: %@", profile);
        return nil;
    }
}

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    NSDictionary *dict = nil;
    return [self initWithDictionary:dict];
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // ID
        _ID = [MKMID IDWithID:[_storeDictionary objectForKey:@"ID"]];
        
        // properties
        _properties = [[NSMutableDictionary alloc] init];
        // data = JsON.encode(properties)
        _data = [_storeDictionary objectForKey:@"data"];
        // signature = User(ID).sign(data)
        NSString *sig = [_storeDictionary objectForKey:@"signature"];
        _signature = [sig base64Decode];
        // verify flag
        _valid = NO;
        
        // public key
        _key = nil;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID
                      data:(nullable NSString *)json
                 signature:(nullable NSData *)signature {
    NSAssert(ID.isValid, @"profile ID error: %@", ID);
    if (self = [super initWithDictionary:@{@"ID": ID}]) {
        // ID
        _ID = ID;
        
        // properties
        _properties = [[NSMutableDictionary alloc] init];
        // json data
        _data = json;
        if (_data != nil) {
            [_storeDictionary setObject:_data forKey:@"data"];
        }
        // signature
        _signature = signature;
        if (_signature != nil) {
            NSString *sig = [_signature base64Encode];
            [_storeDictionary setObject:sig forKey:@"signature"];
        }
        // verify flag
        _valid = NO;
        
        // public key
        _key = nil;
    }
    return self;
}

- (void)setData:(nullable NSObject *)value forKey:(NSString *)key {
    // 1. update data in properties
    if (value != nil) {
        [_properties setObject:value forKey:key];
    } else {
        [_properties removeObjectForKey:key];
    }
    
    // 2. reset data signature after properties changed
    [_storeDictionary removeObjectForKey:@"data"];
    [_storeDictionary removeObjectForKey:@"signature"];
    _data = nil;
    _signature = nil;
    _valid = NO;
}

- (nullable NSObject *)dataForKey:(NSString *)key {
    return _valid ? [_properties objectForKey:key] : nil;
}

- (NSArray *)dataKeys {
    return _valid ? [_properties allKeys] : nil;
}

- (MKMPublicKey *)key {
    return _valid ? _key : nil;
}

- (void)setKey:(MKMPublicKey *)key {
    _key = key;
    [self setData:key forKey:@"key"];
}

- (BOOL)verify:(MKMPublicKey *)PK {
    if (_valid) {
        // already verified
        return YES;
    }
    if (_data == nil || _signature == nil) {
        // data error
        return NO;
    }
    NSData *data = [_data data];
    if ([PK verify:data withSignature:_signature]) {
        _valid = YES;
        // refresh properties
        _properties = [[data jsonDictionary] mutableCopy];
        
        // get public key
        _key = [MKMPublicKey keyWithKey:[_properties objectForKey:@"key"]];
    } else {
        _data = nil;
        _signature = nil;
    }
    return _valid;
}

- (NSData *)sign:(MKMPrivateKey *)SK {
    if (_valid) {
        // already signed
        return _signature;
    }
    NSData *data = [_properties jsonData];
    _data = [data UTF8String];
    _signature = [SK sign:data];
    // update 'data' & 'signature' fields
    [_storeDictionary setObject:_data forKey:@"data"];
    [_storeDictionary setObject:[_signature base64Encode] forKey:@"signature"];
    _valid = YES;
    return _signature;
}

@end

#pragma mark - Profile

@implementation MKMProfile

- (NSString *)name {
    return (NSString *)[self dataForKey:@"name"];
}

- (void)setName:(NSString *)name {
    [self setData:name forKey:@"name"];
}

@end
