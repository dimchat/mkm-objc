//
//  MKMCryptographyKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "MKMCryptographyKey.h"

@interface MKMCryptographyKey ()

@property (strong, nonatomic) NSString *algorithm;

@end

@implementation MKMCryptographyKey

+ (instancetype)keyWithKey:(id)key {
    if ([key isKindOfClass:[MKMCryptographyKey class]]) {
        return key;
    } else if ([key isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:key];
    } else {
        NSAssert(!key, @"unexpected key: %@", key);
        return nil;
    }
}

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    NSDictionary *dict = nil;
    self = [self initWithDictionary:dict];
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        // lazy
        _algorithm = nil;
    }
    return self;
}

- (instancetype)initWithAlgorithm:(const NSString *)algorithm {
    NSDictionary *keyInfo = @{@"algorithm":algorithm};
    self = [self initWithDictionary:keyInfo];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMCryptographyKey *key = [super copyWithZone:zone];
    if (key) {
        key.algorithm = _algorithm;
        key.data = _data;
    }
    return key;
}

- (NSString *)algorithm {
    if (!_algorithm) {
        _algorithm = [_storeDictionary objectForKey:@"algorithm"];
        NSAssert(_algorithm, @"key info error: %@", _storeDictionary);
    }
    return _algorithm;
}

- (void)setData:(NSData *)data {
    _data = data;
}

@end

@implementation MKMCryptographyKey (Runtime)

+ (void)registerClass:(nullable Class)clazz forAlgorithm:(const NSString *)name {
    NSAssert(false, @"override me!");
}

+ (nullable instancetype)getInstance:(id)key {
    NSAssert(false, @"override me!");
    return nil;
}

@end

@implementation MKMCryptographyKey (PersistentStore)

+ (nullable instancetype)loadKeyWithIdentifier:(const NSString *)identifier {
    NSAssert(false, @"override me!");
    return nil;
}

- (BOOL)saveKeyWithIdentifier:(const NSString *)identifier {
    NSAssert(false, @"override me in subclass");
    // let the subclass to do the job
    return NO;
}

@end
