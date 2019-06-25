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
    
    MKMID *_ID;
    
    NSString *_data;    // JsON.encode(properties)
    NSData *_signature; // User(ID).sign(data)
    
    NSMutableDictionary *_properties;
    
    BOOL _valid; // YES on signature matched
}

@end

@implementation MKMTAO

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    NSDictionary *dict = nil;
    return [self initWithDictionary:dict];
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // ID
        _ID = MKMIDFromString([_storeDictionary objectForKey:@"ID"]);
        
        // properties
        _properties = [[NSMutableDictionary alloc] init];
        // data = JsON.encode(properties)
        _data = [_storeDictionary objectForKey:@"data"];
        // signature = User(ID).sign(data)
        NSString *sig = [_storeDictionary objectForKey:@"signature"];
        _signature = [sig base64Decode];
        
        // verify flag
        _valid = NO;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(MKMID *)ID
                      data:(nullable NSString *)json
                 signature:(nullable NSData *)signature {
    NSAssert([ID isValid], @"profile ID error: %@", ID);
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
    }
    return self;
}

- (instancetype)initWithID:(MKMID *)ID {
    return [self initWithID:ID data:nil signature:nil];
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
    //} else {
    //    _data = nil;
    //    _signature = nil;
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

@interface MKMProfile () {
    NSString *_name;          // nickname
    MKMPublicKey *_key; // public key
}

@end

@implementation MKMProfile

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        _name = nil;
        _key = nil;
    }
    return self;
}

- (instancetype)initWithID:(MKMID *)ID data:(NSString *)json signature:(NSData *)signature {
    if (self = [super initWithID:ID data:json signature:signature]) {
        _name = nil;
        _key = nil;
    }
    return self;
}

- (BOOL)verify:(MKMPublicKey *)PK {
    if (![super verify:PK]) {
        return NO;
    }
    _name = (NSString *)[self dataForKey:@"name"];
    _key = MKMPublicKeyFromDictionary([self dataForKey:@"key"]);
    return YES;
}

- (NSString *)name {
    return _name;
}

- (void)setName:(NSString *)name {
    _name = name;
    [self setData:name forKey:@"name"];
}

- (nullable MKMPublicKey *)key {
    return _key;
}

- (void)setKey:(MKMPublicKey *)key {
    _key = key;
    [self setData:(NSObject *)key forKey:@"key"];
}

@end

static NSMutableArray<Class> *profile_classes(void) {
    static NSMutableArray<Class> *classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = [[NSMutableArray alloc] init];
        // default
        [classes addObject:[MKMProfile class]];
        // ...
    });
    return classes;
}

@implementation MKMProfile (Runtime)

+ (void)registerClass:(Class)clazz {
    NSAssert(![clazz isEqual:self], @"only subclass");
    NSAssert([clazz isSubclassOfClass:self], @"profile class error: %@", clazz);
    NSMutableArray<Class> *classes = profile_classes();
    if (clazz && ![classes containsObject:clazz]) {
        // parse profile with new class first
        [classes insertObject:clazz atIndex:0];
    }
}

+ (nullable instancetype)getInstance:(id)profile {
    if (!profile) {
        return nil;
    }
    if ([profile isKindOfClass:[MKMProfile class]]) {
        // return Profile object directly
        return profile;
    }
    NSAssert([profile isKindOfClass:[NSDictionary class]],
             @"profile should be a dictionary: %@", profile);
    // create instance by subclass
    NSMutableArray<Class> *classes = profile_classes();
    for (Class clazz in classes) {
        @try {
            return [[clazz alloc] initWithDictionary:profile];
        } @catch (NSException *exception) {
            // profile not match, try next
        } @finally {
            //
        }
    }
    NSAssert(false, @"profile not support: %@", profile);
    return nil;
}

@end
