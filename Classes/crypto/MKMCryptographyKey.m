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
    } else if ([key isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:key];
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

- (instancetype)initWithJSONString:(const NSString *)json {
    NSDictionary *dict = [[json data] jsonDictionary];
    self = [self initWithDictionary:dict];
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

+ (MKMCryptographyKeyMap *)keyClasses {
    NSAssert(false, @"override me in subclass");
    // let the subclass to manage the classes
    return nil;
}

+ (void)registerClass:(nullable Class)clazz forAlgorithm:(const NSString *)name {
    NSAssert(name.length > 0, @"algorithm cannot be empty");
    NSAssert([clazz isSubclassOfClass:self], @"class error: %@", clazz);
    if (clazz) {
        [[self keyClasses] setObject:clazz forKey:name];
    } else {
        [[self keyClasses] removeObjectForKey:name];
    }
}

+ (nullable Class)classForAlgorithm:(const NSString *)name {
    return [[self keyClasses] objectForKey:name];
}

@end

@implementation MKMCryptographyKey (PersistentStore)

+ (nullable instancetype)loadKeyWithIdentifier:(const NSString *)identifier {
    MKMCryptographyKey *key = nil;
    NSArray<Class> *classes = [[self keyClasses] allValues];
    Class clazz;
    for (clazz in classes) {
        key = [clazz loadKeyWithIdentifier:identifier];
        if (key) {
            // found
            NSAssert([[key class] isSubclassOfClass:self], @"key error: %@", key);
            break;
        }
    }
    return key;
}

- (BOOL)saveKeyWithIdentifier:(const NSString *)identifier {
    NSAssert(false, @"override me in subclass");
    // let the subclass to do the job
    return NO;
}

@end
