//
//  MKMProfile.m
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
#import "MKMLocalUser.h"

#import "MKMProfile.h"

@interface MKMTAI () {
    
    MKMID *_ID;
    
    NSMutableDictionary *_properties;
    
    NSString *_data;    // JsON.encode(properties)
    NSData *_signature; // User(ID).sign(data)
    
    BOOL _valid; // YES on signature matched
}

@property (strong, nonatomic) MKMID *ID;

@property (strong, nonatomic) NSMutableDictionary *properties;

@property (strong, nonatomic) NSString *data;
@property (strong, nonatomic) NSData *signature;

@property (nonatomic, getter=isValid) BOOL valid;

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
        
        _valid = NO; // verify flag
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

- (id)copyWithZone:(NSZone *)zone {
    MKMTAI *profile = [super copyWithZone:zone];
    if (profile) {
        profile.ID = _ID;
        profile.properties = _properties;
        profile.data = _data;
        profile.signature = _signature;
        profile.valid = _valid;
    }
    return profile;
}

- (MKMID *)ID {
    if (!_ID) {
        _ID = MKMIDFromString([_storeDictionary objectForKey:@"ID"]);
    }
    return _ID;
}

- (NSMutableDictionary *)properties {
    if (!_properties) {
        _properties = [[NSMutableDictionary alloc] init];
    }
    return _properties;
}

- (NSString *)data {
    if (!_data) {
        _data = [_storeDictionary objectForKey:@"data"];
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

- (void)setData:(nullable NSObject *)value forKey:(NSString *)key {
    // 1. update data in properties
    if (value != nil) {
        [self.properties setObject:value forKey:key];
    } else {
        [self.properties removeObjectForKey:key];
    }
    
    // 2. reset data signature after properties changed
    [_storeDictionary removeObjectForKey:@"data"];
    [_storeDictionary removeObjectForKey:@"signature"];
    _data = nil;
    _signature = nil;
    _valid = NO;
}

- (nullable NSObject *)dataForKey:(NSString *)key {
    return self.valid ? [self.properties objectForKey:key] : nil;
}

- (NSArray *)dataKeys {
    return self.valid ? [self.properties allKeys] : nil;
}

- (BOOL)verify:(MKMPublicKey *)PK {
    if (self.valid) {
        // already verified
        return YES;
    }
    if (self.data == nil || self.signature == nil) {
        // data error
        return NO;
    }
    NSData *data = [self.data data];
    if ([PK verify:data withSignature:self.signature]) {
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
    if (self.valid) {
        // already signed
        return _signature;
    }
    NSData *data = [self.properties jsonData];
    _data = [data UTF8String];
    _signature = [SK sign:data];
    NSString *signature = [self.signature base64Encode];
    // update 'data' & 'signature' fields
    [_storeDictionary setObject:self.data forKey:@"data"];
    [_storeDictionary setObject:signature forKey:@"signature"];
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
    SingletonDispatchOnce(^{
        classes = [[NSMutableArray alloc] init];
        // extended profile...
    });
    return classes;
}

@implementation MKMProfile (Runtime)

+ (void)registerClass:(Class)clazz {
    NSAssert(![clazz isEqual:self], @"only subclass");
    NSAssert([clazz isSubclassOfClass:self], @"error: %@", clazz);
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
    NSAssert([profile isKindOfClass:[NSDictionary class]], @"profile error: %@", profile);
    if ([self isEqual:[MKMProfile class]]) {
        // try to create instance by each subclass
        MKMProfile *tai = nil;
        NSMutableArray<Class> *classes = profile_classes();
        for (Class clazz in classes) {
            @try {
                tai = [clazz getInstance:profile];
                if (tai) {
                    // create by this subclass successfully
                    break;
                }
            } @catch (NSException *exception) {
                // profile not match? try next
            } @finally {
                //
            }
        }
        if (tai) {
            return tai;
        }
    }
    // subclass
    return [[self alloc] initWithDictionary:profile];
}

@end
