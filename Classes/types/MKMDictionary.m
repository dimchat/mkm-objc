//
//  MKMDictionary.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/27.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "MKMDictionary.h"

@implementation MKMDictionary

- (instancetype)initWithJSONString:(const NSString *)jsonString {
    NSData *data = [jsonString data];
    NSDictionary *dict = [data jsonDictionary];
    self = [self initWithDictionary:dict];
    return self;
}

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _storeDictionary = [[NSMutableDictionary alloc] initWithDictionary:dict];
    }
    return self;
}

/* designated initializer */
- (instancetype)init {
    if (self = [super init]) {
        _storeDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithObjects:(const id _Nonnull [_Nullable])objects
                        forKeys:(const id <NSCopying> _Nonnull [_Nullable])keys
                          count:(NSUInteger)cnt {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
    return [self initWithDictionary:dict];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSDictionary *dict = [[NSDictionary alloc] initWithCoder:aDecoder];
    return [self initWithDictionary:dict];
}

- (id)copyWithZone:(NSZone *)zone {
    id dict = [[self class] allocWithZone:zone];
    dict = [dict initWithDictionary:_storeDictionary];
    return dict;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    return [_storeDictionary isEqualToDictionary:object];
}

- (NSUInteger)count {
    return [_storeDictionary count];
}

- (id)objectForKey:(const NSString *)aKey {
    return [_storeDictionary objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator {
    return [_storeDictionary keyEnumerator];
}

- (NSEnumerator *)objectEnumerator {
    return [_storeDictionary objectEnumerator];
}

@end

@implementation MKMDictionary (Mutable)

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    if (self = [self init]) {
        _storeDictionary = [[NSMutableDictionary alloc] initWithCapacity:numItems];
    }
    return self;
}

// NOTICE: no need to implements mutable copy here
//- (id)mutableCopy {
//    return [self copy];
//}

- (void)removeObjectForKey:(const NSString *)aKey {
    [_storeDictionary removeObjectForKey:aKey];
}

- (void)setObject:(id)anObject forKey:(const NSString *)aKey {
    [_storeDictionary setObject:anObject forKey:aKey];
}

@end
