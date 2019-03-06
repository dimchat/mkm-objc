//
//  MKMEntity.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"

#import "MKMID.h"

#import "MKMProfile.h"
#import "MKMBarrack.h"

#import "MKMEntity.h"

@implementation MKMEntity

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    MKMID *ID = nil;
    self = [self initWithID:ID];
    return self;
}

/* designated initializer */
- (instancetype)initWithID:(const MKMID *)ID {
    NSAssert([ID isValid], @"Invalid ID");
    if (self = [super init]) {
        _ID = [ID copy];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMEntity *entity = [[self class] allocWithZone:zone];
    entity = [entity initWithID:_ID];
    if (entity) {
        self.dataSource = _dataSource;
    }
    return entity;
}

- (BOOL)isEqual:(id)object {
    MKMEntity *entity = (MKMEntity *)object;
    return [entity.ID isEqual:_ID];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p | p = %@; t = 0x%02X; n = %d>",
            [self class], self, [self debugDescription], _ID.type, _ID.number];
}

- (NSString *)debugDescription {
    NSDictionary *info = @{
                           @"ID"   : self.ID,
                           @"name" : self.name,
                           };
    return [info jsonString];
}

- (MKMNetworkType)type {
    return _ID.type;
}

- (UInt32)number {
    return _ID.number;
}

- (MKMMeta *)meta {
    NSAssert(_dataSource, @"entity data source not set yet");
    return [_dataSource metaForEntity:self];
}

- (NSString *)name {
    NSString *nick = [_dataSource nameOfEntity:self];
    if (nick.length > 0) {
        return nick;
    }
    nick = _ID.name;
    if (nick.length > 0) {
        return nick;
    }
    return _ID.address; // BTC Address
}

@end
