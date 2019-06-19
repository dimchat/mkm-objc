//
//  MKMCryptographyKey.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "MKMCryptographyKey.h"

@implementation MKMCryptographyKey

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    NSDictionary *dict = nil;
    return [self initWithDictionary:dict];
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)keyInfo {
    if (self = [super initWithDictionary:keyInfo]) {
        _algorithm = [_storeDictionary objectForKey:@"algorithm"];
        _data = nil;
    }
    return self;
}

- (instancetype)initWithAlgorithm:(NSString *)algorithm {
    NSDictionary *keyInfo = @{@"algorithm":algorithm};
    return [self initWithDictionary:keyInfo];
}

@end

@implementation MKMCryptographyKey (Runtime)

+ (void)registerClass:(nullable Class)clazz forAlgorithm:(NSString *)name {
    NSAssert(false, @"override me!");
}

+ (nullable instancetype)getInstance:(id)key {
    NSAssert(false, @"override me!");
    return nil;
}

@end

@implementation MKMCryptographyKey (PersistentStore)

+ (nullable instancetype)loadKeyWithIdentifier:(NSString *)identifier {
    NSAssert(false, @"override me!");
    return nil;
}

- (BOOL)saveKeyWithIdentifier:(NSString *)identifier {
    NSAssert(false, @"override me!");
    return NO;
}

@end
