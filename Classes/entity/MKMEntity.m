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
//  MKMEntity.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMDataParser.h"

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
    return MKMUTF8Decode(MKMJSONEncode(info));
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
