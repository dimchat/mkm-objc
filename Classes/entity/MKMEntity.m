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

#import "MKMEntity.h"

@implementation MKMEntity

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    MKMID *ID = nil;
    return [self initWithID:ID];
}

/* designated initializer */
- (instancetype)initWithID:(MKMID *)ID {
    NSAssert([ID isValid], @"Invalid entity ID: %@", ID);
    if (self = [super init]) {
        _ID = ID;
        _dataSource = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMEntity *entity = [[self class] allocWithZone:zone];
    entity = [entity initWithID:_ID];
    if (entity) {
        entity.dataSource = _dataSource;
    }
    return entity;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[MKMEntity class]]) {
        return NO;
    }
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

- (NSString *)name {
    // get from profile
    MKMProfile *profile = [self profile];
    NSString *nickname = [profile name];
    if ([nickname length] > 0) {
        return nickname;
    }
    // get from ID.name
    return _ID.name;
}

- (MKMMeta *)meta {
    NSAssert(_dataSource, @"entity data source not set yet");
    return [_dataSource metaForID:_ID];
}

- (nullable __kindof MKMProfile *)profile {
    NSAssert(_dataSource, @"entity data source not set yet");
    return [_dataSource profileForID:_ID];
}

@end
